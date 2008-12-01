Message-ID: <49344C11.6090204@cs.columbia.edu>
Date: Mon, 01 Dec 2008 15:41:53 -0500
From: Oren Laadan <orenl@cs.columbia.edu>
MIME-Version: 1.0
Subject: Re: [RFC v10][PATCH 09/13] Restore open file descriprtors
References: <1227747884-14150-1-git-send-email-orenl@cs.columbia.edu>	 <1227747884-14150-10-git-send-email-orenl@cs.columbia.edu>	 <20081128112745.GR28946@ZenIV.linux.org.uk> <1228159324.2971.74.camel@nimitz>
In-Reply-To: <1228159324.2971.74.camel@nimitz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>



Dave Hansen wrote:
> On Fri, 2008-11-28 at 11:27 +0000, Al Viro wrote:
>> On Wed, Nov 26, 2008 at 08:04:40PM -0500, Oren Laadan wrote:
>>> +/**
>>> + * cr_attach_get_file - attach (and get) lonely file ptr to a file descriptor
>>> + * @file: lonely file pointer
>>> + */
>>> +static int cr_attach_get_file(struct file *file)
>>> +{
>>> +	int fd = get_unused_fd_flags(0);
>>> +
>>> +	if (fd >= 0) {
>>> +		fsnotify_open(file->f_path.dentry);
>>> +		fd_install(fd, file);
>>> +		get_file(file);
>>> +	}
>>> +	return fd;
>>> +}
>> What happens if another thread closes the descriptor in question between
>> fd_install() and get_file()?
> 
> You're just saying to flip the get_file() and fd_install()?

Indeed.

> 
>>> +	fd = cr_attach_file(file);	/* no need to cleanup 'file' below */
>>> +	if (fd < 0) {
>>> +		filp_close(file, NULL);
>>> +		ret = fd;
>>> +		goto out;
>>> +	}
>>> +
>>> +	/* register new <objref, file> tuple in hash table */
>>> +	ret = cr_obj_add_ref(ctx, file, parent, CR_OBJ_FILE, 0);
>>> +	if (ret < 0)
>>> +		goto out;
>> Who said that file still exists at that point?

Correct. This call should move higher up befor ethe call to cr_attach_file()

> 
> Ahhh.  We're depending on the 'struct file' reference that comes from
> the fd table.  That's why there is supposedly "no need to cleanup 'file'
> below".  But, some other thread can come along and close() the fd, which
> will __fput() our poor 'struct file' and will make it go away.  Next
> time we go and pull it out of the hash table, we go boom.
> 
> As a quick fix, I think we can just take another get_file() here.  But,
> as Al notes, there are some much larger issues that we face with the
> fd_table and multi-thread access.  They haven't "mattered" to us so far
> because we assume everything is either single-threaded or frozen.
> Sounds like Al isn't comfortable with this being integrated until a much
> more detailed look has been taken.
> 
>> BTW, there are shitloads of races here - references to fd and struct file *
>> are mixed in a way that breaks *badly* if descriptor table is played with
>> by another thread.

The assumption about tasks being frozen and no additional sharing is generally
more strict, more likely to hold, and easier to enforce for the restart.

Besides the race pointed above which would crash the kernel, the other races
are "ok" - if the user abuses the interface, then the results are "undefined"
(refer to my reply to "..PATCH 808/13] Dump open file descriptors").

Here, too, by "undefined" I mean that the restart syscall may fail, and if it
completes successfully the resulting set of tasks is not guaranteed to behave
correctly. In contrast, if the user uses the interface correctly (ensuring
that the assumption holds), then restart is guaranteed to succeed. Note that
even when the outcome is undefined, there are no security issues - all actions
are limited to what the initiating user can do.

> One of the things about this that bothers me is that it shares too
> little with existing VFS code.  It calls into a ton of existing stuff
> but doesn't refactor anything that is currently there.  Surely there are
> some common bits somewhere in the VFS that could be consolidated here.  

Actually, the code alternates between "file" and "fd", in attempt to resuse
existing code and not do things ourselves:

	ret = sys_fcntl(fd, F_SETFL, hh->f_flags & CR_SETFL_MASK);
        if (ret < 0)
        	goto out;
        ret = vfs_llseek(file, hh->f_pos, SEEK_SET);
        if (ret == -ESPIPE)     /* ignore error on non-seekable files */
                ret = 0;

This is still safe: the file struct is protected with a reference count. If
the fd no longer points to the same struct file, then either it will fail
(e.g. if the fd is invalid) or the restart will eventually succeed but the
resulting state of the tasks will be incorrect (that is: undefined behavior).

Oren.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
