Message-ID: <395A4CBA.D217F0FE@colorfullife.com>
Date: Wed, 28 Jun 2000 21:06:34 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: kmap_kiobuf()
References: <200006281652.LAA19162@jen.americas.sgi.com> <20000628190612.E2392@redhat.com>
Content-Type: multipart/mixed;
 boundary="------------3893FDF532C6E6D35E639D01"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: lord@sgi.com, "Benjamin C.R. LaHaise" <blah@kvack.org>, David Woodhouse <dwmw2@infradead.org>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------3893FDF532C6E6D35E639D01
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

"Stephen C. Tweedie" wrote:
> 
> Hi,
> 
> On Wed, Jun 28, 2000 at 11:52:40AM -0500, lord@sgi.com wrote:
> >
> > I am not a VM guy either, Ben, is the cost of the TLB flush mostly in
> > the synchronization between CPUs, or is it just expensive anyway you
> > look at it?
> 
> The TLB IPI is by far the biggest factor here.
> 
I tried it on my Dual Pentium II/350, 100 MHz FSB:

* an empty IPI returns after ~ 1630 cpu ticks.
* a tlb flush IPI needs ~ 2130 cpu ticks.

The computer was idle, and obviously I only measure the cost as seen
from the primary cpu, I don't know how long the second cpu needs until
it returns from the interrupt.


--
	Manfred
--------------3893FDF532C6E6D35E639D01
Content-Type: text/plain; charset=us-ascii;
 name="patch-newperf"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-newperf"

--- 2.4/drivers/net/dummy.c	Sat Jun 24 11:07:56 2000
+++ build-2.4/drivers/net/dummy.c	Wed Jun 28 20:55:44 2000
@@ -132,17 +132,171 @@
 	dummy_init(dev);
 	return 0;
 }
-
 static struct net_device dev_dummy = {
 		"",
 		0, 0, 0, 0,
 	 	0x0, 0,
 	 	0, 0, 0, NULL, dummy_probe };
 
+/* kernel benchmark hook (C) Manfred Spraul manfreds@colorfullife.com */
+
+int p_shift = -1;
+MODULE_PARM     (p_shift, "1i");
+MODULE_PARM_DESC(p_shift, "Shift for the profile buffer");
+
+#define STAT_TABLELEN		16384
+static unsigned long totals[STAT_TABLELEN];
+static unsigned int overflows;
+
+static unsigned long long stime;
+static void start_measure(void)
+{
+	 __asm__ __volatile__ (
+		".align 64\n\t"
+	 	"pushal\n\t"
+		"cpuid\n\t"
+		"popal\n\t"
+		"rdtsc\n\t"
+		"movl %%eax,(%0)\n\t"
+		"movl %%edx,4(%0)\n\t"
+		: /* no output */
+		: "c"(&stime)
+		: "eax", "edx", "memory" );
+}
+
+static void end_measure(void)
+{
+static unsigned long long etime;
+	__asm__ __volatile__ (
+		"pushal\n\t"
+		"cpuid\n\t"
+		"popal\n\t"
+		"rdtsc\n\t"
+		"movl %%eax,(%0)\n\t"
+		"movl %%edx,4(%0)\n\t"
+		: /* no output */
+		: "c"(&etime)
+		: "eax", "edx", "memory" );
+	{
+		unsigned long time = (unsigned long)(etime-stime);
+		time >>= p_shift;
+		if(time < STAT_TABLELEN) {
+			totals[time]++;
+		} else {
+			overflows++;
+		}
+	}
+}
+
+static void clean_buf(void)
+{
+	memset(totals,0,sizeof(totals));
+	overflows = 0;
+}
+
+static void print_line(unsigned long* array)
+{
+	int i;
+	for(i=0;i<32;i++) {
+		if((i%32)==16)
+			printk(":");
+		printk("%lx ",array[i]); 
+	}
+}
+
+static void print_buf(char* caption)
+{
+	int i, other = 0;
+	printk("Results - %s - shift %d",
+		caption, p_shift);
+
+	for(i=0;i<STAT_TABLELEN;i+=32) {
+		int j;
+		int local = 0;
+		for(j=0;j<32;j++)
+			local += totals[i+j];
+
+		if(local) {
+			printk("\n%3x: ",i);
+			print_line(&totals[i]);
+			other += local;
+		}
+	}
+	printk("\nOverflows: %d.\n",
+		overflows);
+	printk("Sum: %ld\n",other+overflows);
+}
+
+static void return_immediately(void* dummy)
+{
+	return;
+}
+
+/* gross hack */
+static unsigned long mmu_cr4_features;
+
+static void do_flush_tlb(void* dummy)
+{
+	__flush_tlb_all();
+}
+
 int init_module(void)
 {
 	/* Find a name for this unit */
-	int err=dev_alloc_name(&dev_dummy,"dummy%d");
+	int err;
+
+	if(p_shift != -1) {
+		int i;
+		/* empty test measurement: */
+		printk("******** kernel cpu benchmark activated **********\n");
+		clean_buf();
+		schedule_timeout(100);
+		for(i=0;i<100;i++) {
+			start_measure();
+			return_immediately(NULL);
+			return_immediately(NULL);
+			return_immediately(NULL);
+			return_immediately(NULL);
+			end_measure();
+		}
+		print_buf("zero");
+		clean_buf();
+		schedule_timeout(100);
+		for(i=0;i<100;i++) {
+			start_measure();
+			return_immediately(NULL);
+			return_immediately(NULL);
+			smp_call_function(return_immediately,NULL,1,1);
+			return_immediately(NULL);
+			return_immediately(NULL);
+			end_measure();
+		}
+		print_buf("empty smp call");
+		clean_buf();
+		{
+			int tmp;
+			__asm__ __volatile__(
+					"movl %%cr4,%0\n\t"
+					"movl %0,%1\n\t"
+					: "=&r"(tmp)
+					: "m" (mmu_cr4_features));
+		}
+		schedule_timeout(100);
+		for(i=0;i<100;i++) {
+			start_measure();
+			return_immediately(NULL);
+			return_immediately(NULL);
+			smp_call_function(do_flush_tlb,NULL,1,1);
+			return_immediately(NULL);
+			return_immediately(NULL);
+			end_measure();
+		}
+		print_buf("tlb flush");
+		clean_buf();
+	return -EINVAL;
+	}
+
+	err=dev_alloc_name(&dev_dummy,"dummy%d");
 	if(err<0)
 		return err;
 	if (register_netdev(&dev_dummy) != 0)

--------------3893FDF532C6E6D35E639D01--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
