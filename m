MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
From: Roland McGrath <roland@redhat.com>
Subject: Re: [Bugme-new] [Bug 11110] New: Core dumps do not include writable unmodified MAP_PRIVATE maps
In-Reply-To: Daniel Jacobowitz's message of  Thursday, 17 July 2008 17:20:23 -0400 <20080717212023.GA20584@caradoc.them.org>
References: <bug-11110-10286@http.bugzilla.kernel.org/>
	<20080717132317.96e73124.akpm@linux-foundation.org>
	<20080717203930.GA24299@hmsendeavour.rdu.redhat.com>
	<20080717212023.GA20584@caradoc.them.org>
Message-Id: <20080717221329.72A0A1541F8@magilla.localdomain>
Date: Thu, 17 Jul 2008 15:13:29 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Jacobowitz <drow@false.org>
Cc: Neil Horman <nhorman@tuxdriver.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugme-daemon@bugzilla.kernel.org, Oleg Nesterov <oleg@tv-sign.ru>, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

It is the intended behavior that core dumps usually don't contain copies
of unmodified file chunks.  If they did, they would include all the text
of executables and DSOs, and sometimes be far larger than people want
(and take much longer with much more VM and IO load to dump).  

It's already the case that dumps do include MAP_PRIVATE vma's with any
modified pages.  Long ago, the logic did not pay attention to
modifiedness and did include all writable vma's.

You can control this now with /proc/pid/coredump_filter.  If you want to
enhance the logic, like paying attention to VM_EXEC or VM_WRITE, then the
thing to do is add more MMF_DUMP_* bits to distinguish more flavors of vma
to treat differently.  e.g.:

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index d48ff5f..0000000 100644  
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -1160,6 +1160,12 @@ static unsigned long vma_dump_size(struc
 	if (FILTER(MAPPED_PRIVATE))
 		goto whole;
 
+	if (FILTER(MAPPED_PRIVATE_EXEC) && (vma->vm_flags & VM_EXEC))
+		goto whole;
+
+	if (FILTER(MAPPED_PRIVATE_WRITE) && (vma->vm_flags & VM_WRITE))
+		goto whole;
+
 	/*
 	 * If this looks like the beginning of a DSO or executable mapping,
 	 * check for an ELF header.  If we find one, dump the first page to

Once we have whatever additional options folks are interested in, and
play with them for a while, we can think about changing the default
setting of MMF_DUMP_FILTER_DEFAULT.  (Note that Fedora kernels already
change this default to add MMF_DUMP_ELF_HEADERS.)


Thanks,
Roland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
