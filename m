Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id CB1B36B0006
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 17:17:36 -0400 (EDT)
Date: Thu, 11 Apr 2013 14:17:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/5] clear_refs: Sanitize accepted commands declaration
Message-Id: <20130411141735.107e583ca55e619f2e215851@linux-foundation.org>
In-Reply-To: <51669E73.2000301@parallels.com>
References: <51669E5F.4000801@parallels.com>
	<51669E73.2000301@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, 11 Apr 2013 15:28:51 +0400 Pavel Emelyanov <xemul@parallels.com> wrote:

> A new clear-refs type will be added in the next patch, so prepare
> code for that.
> 
> @@ -730,7 +733,7 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
>  	char buffer[PROC_NUMBUF];
>  	struct mm_struct *mm;
>  	struct vm_area_struct *vma;
> -	int type;
> +	enum clear_refs_types type;
>  	int rv;
>  
>  	memset(buffer, 0, sizeof(buffer));
> @@ -738,10 +741,10 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
>  		count = sizeof(buffer) - 1;
>  	if (copy_from_user(buffer, buf, count))
>  		return -EFAULT;
> -	rv = kstrtoint(strstrip(buffer), 10, &type);
> +	rv = kstrtoint(strstrip(buffer), 10, (int *)&type);

This is naughty.  The compiler is allowed to put the enum into storage
which is smaller (or, I guess, larger) than sizeof(int).  I've seen one
compiler which puts such an enum into a 16-bit word.

--- a/fs/proc/task_mmu.c~clear_refs-sanitize-accepted-commands-declaration-fix
+++ a/fs/proc/task_mmu.c
@@ -734,6 +734,7 @@ static ssize_t clear_refs_write(struct f
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	enum clear_refs_types type;
+	int itype;
 	int rv;
 
 	memset(buffer, 0, sizeof(buffer));
@@ -741,9 +742,10 @@ static ssize_t clear_refs_write(struct f
 		count = sizeof(buffer) - 1;
 	if (copy_from_user(buffer, buf, count))
 		return -EFAULT;
-	rv = kstrtoint(strstrip(buffer), 10, (int *)&type);
+	rv = kstrtoint(strstrip(buffer), 10, &itype);
 	if (rv < 0)
 		return rv;
+	type = (enum clear_refs_types)itype;
 	if (type < CLEAR_REFS_ALL || type >= CLEAR_REFS_LAST)
 		return -EINVAL;
 	task = get_proc_task(file_inode(file));
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
