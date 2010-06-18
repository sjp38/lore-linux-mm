Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0FECE6B01AF
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 17:39:25 -0400 (EDT)
Date: Fri, 18 Jun 2010 14:38:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mempolicy: reduce stack size of migrate_pages()
Message-Id: <20100618143851.0661daa2.akpm@linux-foundation.org>
In-Reply-To: <20100616130040.3831.A69D9226@jp.fujitsu.com>
References: <20100616130040.3831.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 16 Jun 2010 13:36:57 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> 
> Now, migrate_pages() are using >500 bytes stack. This patch reduce it.
> 
>    mm/mempolicy.c: In function 'sys_migrate_pages':
>    mm/mempolicy.c:1344: warning: the frame size of 528 bytes is larger than
>    512 bytes
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> ---
>  mm/mempolicy.c |   35 ++++++++++++++++++++++-------------
>  1 files changed, 22 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 13b09bd..1116427 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1275,33 +1275,39 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pid, unsigned long, maxnode,
>  		const unsigned long __user *, new_nodes)
>  {
>  	const struct cred *cred = current_cred(), *tcred;
> -	struct mm_struct *mm;
> +	struct mm_struct *mm = NULL;
>  	struct task_struct *task;
> -	nodemask_t old;
> -	nodemask_t new;
>  	nodemask_t task_nodes;
>  	int err;
> +	NODEMASK_SCRATCH(scratch);
> +	nodemask_t *old = &scratch->mask1;
> +	nodemask_t *new = &scratch->mask2;
>
> +	if (!scratch)
> +		return -ENOMEM;

It doesn't matter in practice, but it makes me all queazy to see code
which plays with pointers which might be NULL.

--- a/mm/mempolicy.c~mempolicy-reduce-stack-size-of-migrate_pages-fix
+++ a/mm/mempolicy.c
@@ -1279,13 +1279,16 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pi
 	struct task_struct *task;
 	nodemask_t task_nodes;
 	int err;
+	nodemask_t *old;
+	nodemask_t *new;
 	NODEMASK_SCRATCH(scratch);
-	nodemask_t *old = &scratch->mask1;
-	nodemask_t *new = &scratch->mask2;
 
 	if (!scratch)
 		return -ENOMEM;
 
+	old = &scratch->mask1;
+	new = &scratch->mask2;
+
 	err = get_nodes(old, old_nodes, maxnode);
 	if (err)
 		goto out;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
