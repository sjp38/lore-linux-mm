In-reply-to: <45DDF8F3.2020304@redhat.com> (message from Peter Staubach on
	Thu, 22 Feb 2007 15:11:31 -0500)
Subject: Re: [PATCH] update ctime and mtime for mmaped write
References: <E1HJvdA-0003Nj-00@dorka.pomaz.szeredi.hu> <45DC8A47.5050900@redhat.com> <E1HJw7l-0003Tq-00@dorka.pomaz.szeredi.hu> <45DC9581.4070909@redhat.com> <E1HJwoe-0003el-00@dorka.pomaz.szeredi.hu> <45DDD498.9050202@redhat.com> <E1HKIUk-0006Sl-00@dorka.pomaz.szeredi.hu> <45DDF8F3.2020304@redhat.com>
Message-Id: <E1HKKmn-0006iw-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 22 Feb 2007 21:43:29 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: staubach@redhat.com
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, hugh@veritas.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > Take this example:
> >
> >     fd = open()
> >     addr = mmap(.., fd)
> >     write(fd, ...)
> >     close(fd)
> >     sleep(100)
> >     msync(addr,...)
> >     munmap(addr)
> >
> > The file times will be updated in write(), but with your patch, the
> > bit in the mapping will also be set.
> >
> > Then in msync() the file times will be updated again, which is wrong,
> > since the memory was _not_ modified through the mapping.
> 
> This is correct.  I have updated my proposed patch to include the clearing
> of AS_MCTIME in the routine which updates the mtime field.

That doesn't really help.  Look at __generic_file_aio_write_nolock().
file_update_time() is called before the data is written, so after the
last write, there will be nothing to clear the flag.

And even if fixed this case by moving the file_update_time() call to
the end of the function, there's no guarantee, that some filesystem
won't do something exotic and call set_page_dirty() indenpendently of
write().  Good luck auditing all the set_page_dirty() calls ;)

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
