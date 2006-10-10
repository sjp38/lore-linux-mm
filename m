Subject: ptrace and pfn mappings
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <452AEC8B.2070008@yahoo.com.au>
References: <20061009140354.13840.71273.sendpatchset@linux.site>
	 <20061009140447.13840.20975.sendpatchset@linux.site>
	 <1160427785.7752.19.camel@localhost.localdomain>
	 <452AEC8B.2070008@yahoo.com.au>
Content-Type: text/plain
Date: Tue, 10 Oct 2006 11:16:27 +1000
Message-Id: <1160442987.32237.34.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Jes Sorensen <jes@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

And the last of my "issues" here:

get_user_pages() can't handle pfn mappings, thus access_process_vm()
can't, and thus ptrace can't. When they were limited to dodgy /dev/mem
things, it was probably ok. But with more drivers needing that, like the
DRM, sound drivers, and now with SPU problem state registers and local
store mapped that way, it's becoming a real issues to be unable to
access any of those mappings from gdb.

The "easy" way out I can see, but it may have all sort of bad side
effects I haven't thought about at this point, is to switch the mm in
access_process_vm (at least if it's hitting such a VMA).

That means that the ptracing process will temporarily be running in the
kernel using a task->active_mm different from task->mm which might have
funny side effects due to assumptions that this won't happen here or
there, though I don't see any fundamental reasons why it couldn't be
made to work.

That do you guys think ? Any better idea ? The problem with mappings
like what SPUfs or the DRM want is that they can change (be remapped
between HW and backup memory, as described in previous emails), thus we
don't want to get struct pages even if available and peek at them as
they might not be valid anymore, same with PFNs (we could imagine
ioremap'ing those PFN's but that would be racy too). The only way that
is guaranteed not to be racy is to do exactly what a user do, that is do
user accesses via the target process vm itself....

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
