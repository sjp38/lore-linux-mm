Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B1B576B007E
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 20:40:46 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e7.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o2I0WF0p015360
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 20:32:15 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2I0ebNa126466
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 20:40:37 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2I0eagj017739
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 20:40:37 -0400
Date: Wed, 17 Mar 2010 16:25:26 -0700
From: Matt Helsley <matthltc@us.ibm.com>
Subject: Re: [C/R v20][PATCH 46/96] c/r: add checkpoint operation for
 opened files of generic filesystems
Message-ID: <20100317232526.GI3037@count0.beaverton.ibm.com>
References: <1268842164-5590-9-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-10-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-11-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-12-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-13-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-14-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-15-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-16-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-17-git-send-email-orenl@cs.columbia.edu>
 <BA0C23DE-E2B5-42A9-8478-CE216D18A6C6@sun.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BA0C23DE-E2B5-42A9-8478-CE216D18A6C6@sun.com>
Sender: owner-linux-mm@kvack.org
To: Andreas Dilger <adilger@sun.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Matt Helsley <matthltc@us.ibm.com>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 17, 2010 at 03:09:00PM -0600, Andreas Dilger wrote:
> On 2010-03-17, at 10:08, Oren Laadan wrote:
> >These patches extend the use of the generic file checkpoint
> >operation to
> >non-extX filesystems which have lseek operations that ensure we
> >can save
> >and restore the files for later use. Note that this does not include
> >things like FUSE, network filesystems, or pseudo-filesystem kernel
> >interfaces.
> 
> I didn't see any other patches posted to linux-fsdevel regarding
> what this code is, or what it is supposed to be doing.  Could you
> please repost the patches related to generic_file_checkpoint(), and

I'm not sure why those weren't sent to linux-fsdevel. It mainly saves
the critical pieces of kernel information from the struct file needed
to restart the open file descriptors. It does not save the file
(system) contents in the checkpoint image. That's left for proper
filesystem freezing, snapshotting, or rsync (for example) depending on
the tools and/or filesystems userspace has chosen.

> the overview email that explains what you mean by "checkpoint".  I'm
> assuming this is related to HPC/process restart/migration, but
> better to not guess.

Your assumption is correct -- this is related to HPC/process
restart/migration. That said, we'd like to make it as useful as
possible for other folks as well.

> 
> >@@ -718,6 +718,7 @@ static const struct file_operations
> >btrfs_ctl_fops = {
> >	.unlocked_ioctl	 = btrfs_control_ioctl,
> >	.compat_ioctl = btrfs_control_ioctl,
> >	.owner	 = THIS_MODULE,
> >+	.checkpoint = generic_file_checkpoint,
> >};
> >
> >const struct file_operations exofs_file_operations = {
> >	.llseek		= generic_file_llseek,
> >+	.checkpoint	= generic_file_checkpoint,
> >	.read		= do_sync_read,
> >	.write		= do_sync_write,
> >	.aio_read	= generic_file_aio_read,
> >
> >static const struct file_operations hostfs_file_fops = {
> >	.llseek		= generic_file_llseek,
> >+	.checkpoint	= generic_file_checkpoint,
> >	.read		= do_sync_read,
> >	.splice_read	= generic_file_splice_read,
> >	.aio_read	= generic_file_aio_read,
> >@@ -430,6 +431,7 @@ static const struct file_operations
> >hostfs_file_fops = {
> >
> >static const struct file_operations hostfs_dir_fops = {
> >	.llseek		= generic_file_llseek,
> >+	.checkpoint	= generic_file_checkpoint,
> >	.readdir	= hostfs_readdir,
> >	.read		= generic_read_dir,
> >};
> >
> >const struct file_operations nilfs_file_operations = {
> >	.llseek		= generic_file_llseek,
> >+	.checkpoint	= generic_file_checkpoint,
> >	.read		= do_sync_read,
> >	.write		= do_sync_write,
> >	.aio_read	= generic_file_aio_read,
> 
> 
> Minor nit - it would be good to add this method in the same place in
> all of the *_file_operation structures for consistency.  Ideally
> these would already be in the order that they are declared in the
> structure, but at least new ones should be added consistently.

I chose to put them right after llseek because that's a critical
operation that determines whether generic_file_checkpoint is suitable
or whether a custom operation is needed. Since the placement here
has nothing to do with the order in memory it's mainly a convention
I thought up to support review of copy-pasted file operations with
new .checkpoint ops.

I'll post a patch to move these down to correspond to definition-order
unless you agree that my reasoning above justifies keeping them
where they are.

> 
> >static const struct vm_operations_struct nfs_file_vm_ops = {
> >	.fault = filemap_fault,
> >	.page_mkwrite = nfs_vm_page_mkwrite,
> >+#ifdef CONFIG_CHECKPOINT
> >+	.checkpoint = filemap_checkpoint,
> >+#endif
> >};
> 
> Why is this one conditional, but the others are not?

filemap_checkpoint is defined in mm/filemap.c and the !CONFIG_CHECKPOINT
section has:

#define filemap_checkpoint NULL

Of course since it's not in a header file that define is useless
elsewhere hence the conditional here. We should move that to a
proper header. Good catch, thanks!

Cheers,
	-Matt Helsley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
