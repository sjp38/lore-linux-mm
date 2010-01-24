Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E33E56B0047
	for <linux-mm@kvack.org>; Sun, 24 Jan 2010 09:17:18 -0500 (EST)
Subject: Re: [RFC -v2 PATCH -mm] change anon_vma linking to fix
 multi-process server scalability issue
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <1264087775.1818.26.camel@barrios-desktop>
References: <20100117222140.0f5b3939@annuminas.surriel.com>
	 <20100121133448.73BD.A69D9226@jp.fujitsu.com> <4B57E442.5060700@redhat.com>
	 <1264087775.1818.26.camel@barrios-desktop>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 24 Jan 2010 23:17:00 +0900
Message-ID: <1264342620.1007.11.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, lwoodman@redhat.com, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, 2010-01-22 at 00:29 +0900, Minchan Kim wrote:
> Hi, Rik. 
> 
> Actually, I tested this patch a few days ago.
> I met problem like you that hang with udev.
> 
> I will debug it when I have a time. :)
> 

Today, I tried to debug but don't get any useful clue.
I tried it by following debug patch and got following 
result.

It means anon_vma_chain has wrong entry.
But I don't know why it happens. 

I tried to found wrong entry when we adds anon_vma_chain
to vma->anon_vma_chain but can't find it.

I think it might happens when the entry was removed or 
some dangling pointer by someone due to locking problem. 

Is there any chance by SLAB_DESTROY_RCU which 
reusing SLAB page? 


== RESULT ==

 ^[[33m*^[[39;49m PulseAudio configured for per-user sessions
saned disabled; edit /etc/default/saned
 * Starting System Tools Backends system-tools-backends       ^[[80G ^M^[[74G[ OK ]
 * Starting anac(h)ronistic cron anacron       ^[[80G ^M^[[74G[ OK ]
 * Starting deferred execution scheduler atd       ^[[80G ^M^[[74G[ OK ]
 * Starting periodic command scheduler crond       ^[[80G ^M^[[74G[ OK ]
 * Enabling additional executable binary formats binfmt-support       ^[[80G ^M^[[74G[ OK ]
 * Checking battery state...       ^[[80G ^M^[[74G[ OK ]
count 1 avc f63abce4 magic 21 vma f63876e0
------------[ cut here ]------------
kernel BUG at mm/rmap.c:282!
invalid opcode: 0000 [#1] SMP
last sysfs file: /sys/devices/pci0000:00/0000:00:01.1/host0/target0:0:0/0:0:0:0/type
Modules linked in:

Pid: 2920, comm: nautilus Not tainted 2.6.33-rc4-mm1 #39 /
EIP: 0060:[<c02142f8>] EFLAGS: 00010286 CPU: 0
EIP is at unlink_anon_vmas+0xd8/0x100
EAX: 00000031 EBX: f63abce4 ECX: f60bc8c0 EDX: 00000000
ESI: f63abce4 EDI: f63abcec EBP: f6233f10 ESP: f6233edc
 DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
Process nautilus (pid: 2920, ti=f6232000 task=f60bc8c0 task.ti=f6232000)
Stack:
 c082c5b8 00000001 f63abce4 00000015 f63876e0 f628ee10 f63876e0 f6387714
<0> 00000001 f62d51f0 00000000 09950000 b3e7d000 f6233f38 c020b1f8 c03a945e
<0> fffffeff f63876e0 fffffeff c1c03160 f644acb8 f6a7d440 f6387528 f6233f68
Call Trace:
 [<c020b1f8>] ? free_pgtables+0x28/0xe0
 [<c03a945e>] ? __percpu_counter_add+0x9e/0xd0
 [<c0211b72>] ? unmap_region+0xd2/0x120
 [<c0211d88>] ? do_munmap+0x1c8/0x2e0
 [<c0211edd>] ? sys_munmap+0x3d/0x60
 [<c012e3a3>] ? sysenter_do_call+0x12/0x38
Code: 00 00 74 8f 89 f3 8b 45 e4 89 44 24 10 8b 43 18 89 5c 24 08 c7 04 24 b8 c5 82 c0 89 44 24 0c 8b 45 ec 89 44 24 04 e8 66 36 49 00 <0f> 0b eb fe 8d 74 26 00 83 c4 28 5b 5e 5f 5d c3 89 d0 e8 a1 69
EIP: [<c02142f8>] unlink_anon_vmas+0xd8/0x100 SS:ESP 0068:f6233edc
---[ end trace 1536c613246c1ea7 ]---


== DEBUG PATCH ==

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 0d1903a..fd77d90 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -58,6 +58,7 @@ struct anon_vma_chain {
 	struct anon_vma *anon_vma;
 	struct list_head same_vma;	/* locked by mmap_sem & friends */
 	struct list_head same_anon_vma;	/* locked by anon_vma->lock */
+	int magic;			/* for debug */
 };
 
 #ifdef CONFIG_MMU
diff --git a/mm/rmap.c b/mm/rmap.c
index d9feb1d..eed2844 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -255,15 +255,36 @@ static void anon_vma_unlink(struct anon_vma_chain *anon_vma_chain)
 		anon_vma_free(anon_vma);
 }
 
+/* sizeof(struct anon_vma_chain) is less than 0x20.
+ * So kmalloced addr might be aligned by 0x20.
+ * 1 means success, 0 means fail.
+ */
+int validate_anon_vma_chain(struct anon_vma_chain *avc)
+{
+	unsigned int addr = (unsigned int)avc;
+	addr %= 0x20;
+	if (addr) 
+		return 0;
+	return 1;
+	
+}
+
 void unlink_anon_vmas(struct vm_area_struct *vma)
 {
 	struct anon_vma_chain *avc, *next;
+	int count = 0;
 
 	/* Unlink each anon_vma chained to the VMA. */
 	list_for_each_entry_safe(avc, next, &vma->anon_vma_chain, same_vma) {
+		if (!validate_anon_vma_chain(avc)) {
+			printk(KERN_ERR "count %d avc %p magic %d vma %p\n", 
+				count, avc, avc->magic, vma);
+			BUG();
+		}
 		anon_vma_unlink(avc);
 		list_del_init(&avc->same_vma);
 		anon_vma_chain_free(avc);
+		count++;
 	}
 }
 
@@ -282,6 +303,7 @@ static void anon_vma_chain_ctor(void *data)
 
 	INIT_LIST_HEAD(&anon_vma_chain->same_vma);
 	INIT_LIST_HEAD(&anon_vma_chain->same_anon_vma);
+	anon_vma_chain->magic = 0x83;
 }
 
 void __init anon_vma_init(void)




-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
