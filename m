Subject: Re: [patch 0/3] no MAX_ARG_PAGES -v2
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <65dd6fd50706141358i39bba32aq139766c8a1a3de2b@mail.gmail.com>
References: <20070613100334.635756997@chello.nl>
	 <617E1C2C70743745A92448908E030B2A01AF860A@scsmsx411.amr.corp.intel.com>
	 <65dd6fd50706132323i9c760f4m6e23687914d0c46e@mail.gmail.com>
	 <1181810319.7348.345.camel@twins>
	 <65dd6fd50706141358i39bba32aq139766c8a1a3de2b@mail.gmail.com>
Content-Type: text/plain
Date: Fri, 15 Jun 2007 11:24:38 +0200
Message-Id: <1181899478.7348.349.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ollie Wild <aaw@google.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-06-14 at 13:58 -0700, Ollie Wild wrote:

>   A good heuristic, though, might be to limit
> argument size to a percentage (say 25%) of maximum stack size and
> validate this inside copy_strings().

This seems to do:


Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/exec.c |   17 +++++++++++++++++
 1 file changed, 17 insertions(+)

Index: linux-2.6-2/fs/exec.c
===================================================================
--- linux-2.6-2.orig/fs/exec.c	2007-06-15 11:05:09.000000000 +0200
+++ linux-2.6-2/fs/exec.c	2007-06-15 11:05:18.000000000 +0200
@@ -199,6 +199,23 @@ static struct page *get_arg_page(struct 
 	if (ret <= 0)
 		return NULL;
 
+	if (write) {
+		struct rlimit *rlim = current->signal->rlim;
+		unsigned long size = bprm->vma->vm_end - bprm->vma->vm_start;
+
+		/*
+		 * Limit to 1/4-th the stack size for the argv+env strings.
+		 * This ensures that:
+		 *  - the remaining binfmt code will not run out of stack space,
+		 *  - the program will have a reasonable amount of stack left
+		 *    to work from.
+		 */
+		if (size > rlim[RLIMIT_STACK].rlim_cur / 4) {
+			put_page(page);
+			return NULL;
+		}
+	}
+
 	return page;
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
