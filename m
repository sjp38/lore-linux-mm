Date: Sun, 10 Jun 2007 20:27:43 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH 02 of 16] avoid oom deadlock in nfs_create_request
Message-ID: <20070610182743.GD7443@v2.random>
References: <d64cb81222748354bf5b.1181332980@v2.random> <466C3729.7050903@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <466C3729.7050903@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 10, 2007 at 01:38:49PM -0400, Rik van Riel wrote:
> Andrea Arcangeli wrote:
> 
> >When sigkill is pending after the oom killer set TIF_MEMDIE, the task
> >must go away or the VM will malfunction.
> 
> However, if the sigkill is pending against ANOTHER task,
> this patch looks like it could introduce an IO error
> where the system would recover fine before.

The error being returned would be -ENOMEM. But even that should not be
returned because do_exit will run before userland runs again. When I
told about this to Neil he didn't seem to object that do_exit will be
called first so I hope we didn't get it wrong.

The only risk would be if we set TIF_MEMDIE but we kill a task with
SIGTERM, then the I/O error could reach userland if the user catched
the sigterm signal in userland.

I didn't add the warn-on for sigkill, because even if we decide to
send sigterm first, in theory it wouldn't be a kernel issue if we
correctly return -ENOMEM to userland if that is the task that must
exit (we don't support a graceful exit path today, perhaps we never
will). But clearly we don't know if all userland code is capable of
coping with a -ENOMEM, so for now we don't have to worry thanks to the
sigkill.

> Tasks that do not have a pending SIGKILL should retry
> the allocation, shouldn't they?

All tasks not having TIF_MEMDIE set (and currently sigkill pending as
well) should retry yes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
