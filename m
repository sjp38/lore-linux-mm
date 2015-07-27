Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id DDCD56B0253
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 15:34:59 -0400 (EDT)
Received: by qges31 with SMTP id s31so12918463qge.3
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 12:34:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g32si22137794qgg.124.2015.07.27.12.34.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jul 2015 12:34:59 -0700 (PDT)
Message-ID: <1438025696.31680.24.camel@redhat.com>
Subject: Re: [PATCH 1/1] mm, mpx: add "vm_flags_t vm_flags" arg to
 do_mmap_pgoff()
From: Mark Salter <msalter@redhat.com>
Date: Mon, 27 Jul 2015 15:34:56 -0400
In-Reply-To: <CAP=VYLp+5Co5PyHcbfkdkNUmyy259DuG4ov=+da+UeRAGFUe1Q@mail.gmail.com>
References: 
	<1436784852-144369-1-git-send-email-kirill.shutemov@linux.intel.com>
	 <1436784852-144369-3-git-send-email-kirill.shutemov@linux.intel.com>
	 <20150713165323.GA7906@redhat.com> <55A3EFE9.7080101@linux.intel.com>
	 <20150716110503.9A4F5196@black.fi.intel.com>
	 <55A7D38C.7070907@linux.intel.com>
	 <20150716160927.GA27037@node.dhcp.inet.fi>
	 <20150716222603.GA21791@redhat.com> <20150716222621.GB21791@redhat.com>
	 <CAP=VYLp+5Co5PyHcbfkdkNUmyy259DuG4ov=+da+UeRAGFUe1Q@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>, Oleg Nesterov <oleg@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave.hansen@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>, Thomas Gleixner <tglx@linutronix.de>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>

On Fri, 2015-07-24 at 10:39 -0400, Paul Gortmaker wrote:
> On Thu, Jul 16, 2015 at 6:26 PM, Oleg Nesterov <oleg@redhat.com> wrote:
> > Add the additional "vm_flags_t vm_flags" argument to do_mmap_pgoff(),
> > rename it to do_mmap(), and re-introduce do_mmap_pgoff() as a simple
> > wrapper on top of do_mmap(). Perhaps we should update the callers of
> > do_mmap_pgoff() and kill it later.
> 
> It seems that the version of this patch in linux-next breaks all nommu
> builds (m86k, some arm, etc).
> 
> mm/nommu.c: In function 'do_mmap':
> mm/nommu.c:1248:30: error: 'vm_flags' redeclared as different kind of symbol
> mm/nommu.c:1241:15: note: previous definition of 'vm_flags' was here
> scripts/Makefile.build:258: recipe for target 'mm/nommu.o' failed
> 
> http://kisskb.ellerman.id.au/kisskb/buildresult/12470285/
> 
> Bisect says:
> 
> 31705a3a633bb63683918f055fe6032939672b61 is the first bad commit
> commit 31705a3a633bb63683918f055fe6032939672b61
> Author: Oleg Nesterov <oleg@redhat.com>
> Date:   Fri Jul 24 09:20:30 2015 +1000
> 
>     mm, mpx: add "vm_flags_t vm_flags" arg to do_mmap_pgoff()
> 
> Paul.

This fixes the build error and runs fine on c6x:

diff --git a/mm/nommu.c b/mm/nommu.c
index 530eea5..af2196e 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1245,7 +1245,7 @@ unsigned long do_mmap(struct file *file,
 	struct vm_area_struct *vma;
 	struct vm_region *region;
 	struct rb_node *rb;
-	unsigned long capabilities, vm_flags, result;
+	unsigned long capabilities, result;
 	int ret;
 
 	*populate = 0;
@@ -1263,7 +1263,7 @@ unsigned long do_mmap(struct file *file,
 
 	/* we've determined that we can make the mapping, now translate what we
 	 * now know into VMA flags */
-	vm_flags = determine_vm_flags(file, prot, flags, capabilities);
+	vm_flags |= determine_vm_flags(file, prot, flags, capabilities);
 
 	/* we're going to need to record the mapping */
 	region = kmem_cache_zalloc(vm_region_jar, GFP_KERNEL);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
