Subject: Re: [PATCH -mm -v4 1/3] i386/x86_64 boot: setup data
From: "Huang, Ying" <ying.huang@intel.com>
In-Reply-To: <200710090228.09841.nickpiggin@yahoo.com.au>
References: <1191912010.9719.18.camel@caritas-dev.intel.com>
	 <200710090206.22383.nickpiggin@yahoo.com.au>
	 <1191920123.9719.71.camel@caritas-dev.intel.com>
	 <200710090228.09841.nickpiggin@yahoo.com.au>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Tue, 09 Oct 2007 17:26:17 +0800
Message-Id: <1191921977.9719.83.camel@caritas-dev.intel.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@suse.de>, "Eric W. Biederman" <ebiederm@xmission.com>, akpm@linux-foundation.org, Yinghai Lu <yhlu.kernel@gmail.com>, Chandramouli Narayanan <mouli@linux.intel.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-10-09 at 02:28 +1000, Nick Piggin wrote:
> On Tuesday 09 October 2007 18:55, Huang, Ying wrote:
> > On Tue, 2007-10-09 at 02:06 +1000, Nick Piggin wrote:
> 
> > > I'm just wondering whether you really need to access highmem in
> > > boot code...
> >
> > Because the zero page (boot_parameters) of i386 boot protocol has 4k
> > limitation, a linked list style boot parameter passing mechanism (struct
> > setup_data) is proposed by Peter Anvin. The linked list is provided by
> > bootloader, so it is possible to be in highmem region.
> 
> OK. I don't really know the code, but I trust you ;)

Thank you :)

> 
> > > Definitely on most architectures it would just amount to
> > > memcpy(dst, __va(phys), n);, right? However I don't know if
> >
> > Yes.
> >
> > > it's worth the trouble of overriding it unless there is some
> > > non-__init user of it.
> >
> > To support debugging and kexec, the boot parameters include the linked
> > list above are exported into sysfs. This function is used there too. The
> > patch is the No. 2 of the series.
> 
> Ah, I see. I missed that.
> 
> OK, well rather than make it weak, and have everyone except
> i386 override it, can you just ifdef CONFIG_HIGHMEM?

Yes. This is better. I will do it. Maybe it can be defined as a macro
for these architectures, as follow:

/* in linux/mm.h */
#ifdef CONFIG_HIGHMEM
void *copy_from_phys(void *to, unsigned long from_phys, size_t n);
#else
#define copy_from_phys(dst, phys, n)	memcpy(dst, __va(phys), n)
#endif

> After that, I guess most other architectures wouldn't even
> use the function. Maybe it can go into lib/ instead so that
> it can be discarded by the linker if it isn't used?

Yes. I will do it.

Best Regards,
Huang Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
