Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C916A6B02A4
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 19:28:28 -0400 (EDT)
Message-ID: <4C520E97.4010703@cs.columbia.edu>
Date: Thu, 29 Jul 2010 19:28:23 -0400
From: Oren Laadan <orenl@cs.columbia.edu>
MIME-Version: 1.0
Subject: [FS/MM TOPIC]  Support for checkpoint/restart in fs/mm
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: lsf10-pc@lists.linuxfoundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Linux Containers <containers@lists.linux-foundation.org>
List-ID: <linux-mm.kvack.org>

[Topic]
Support for checkpoint/restart in fs/mm.

[Abstract]
Linux-CR implements transparent application checkpoint-restart
aiming for inclusion in the mainline kernel. We'd like to briefly
present our approach, and discuss pending issues. (for more info
on linux-cr: http://www.linux-cr.org/)

* Quick review of the approach:

Checkpoint: we add .checkpoint method to 'struct file_operations",
(which so far simply calls a generic checkpoint function).
Restart: to restore the state of an open fd we reopen it based on
the pathname saved during checkpoint, and then some adjustments.

* Handling of unlinked files:

Unlinked files are accessible by their open fd only, but at
restart the fd cannot be restored (re-opened) since the original
pathname is gone. We'd like to suggset a .relink filesystem
method to attach a (new) pathname to an existing inode.

* Handling of fsnotify/inotify:

Both fsnotify/inotify track inode(s) directly without respective
dentry(s). However, to restore an inotify fd, we need to have had
recorded the pathname to that inode to re-add the watch at restart.
We'd like to discuss possibilities for doing so.

* Tracking of mm/pages modification per-process:

We envision two optimizations - pre-copy (for fast live-migration)
and incremental checkpoints. Both require tracking memory changes
such as mm layout and modified pages. Tracking needs to be done on
a per-process basis. We'd like to discuss possible approaches.

Thanks,

Oren.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
