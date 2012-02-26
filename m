Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 921CF6B007E
	for <linux-mm@kvack.org>; Sun, 26 Feb 2012 03:44:04 -0500 (EST)
Date: Sun, 26 Feb 2012 08:44:03 +0000
From: Eric Wong <normalperson@yhbt.net>
Subject: Re: [PATCH] fadvise: avoid EINVAL if user input is valid
Message-ID: <20120226084403.GA4641@dcvr.yhbt.net>
References: <20120225022710.GA29455@dcvr.yhbt.net>
 <CAJd=RBDHB8yM=LGkzhOWZO6ftYFyZ42SQKySc0hUzNEQzrmVTw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAJd=RBDHB8yM=LGkzhOWZO6ftYFyZ42SQKySc0hUzNEQzrmVTw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hillf Danton <dhillf@gmail.com> wrote:
> On Sat, Feb 25, 2012 at 10:27 AM, Eric Wong <normalperson@yhbt.net> wrote:
> > index 469491e0..f9e48dd 100644
> > --- a/mm/fadvise.c
> > +++ b/mm/fadvise.c
> > @@ -43,13 +43,13 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, loff_t len, int advice)
> > A  A  A  A  A  A  A  A goto out;
> > A  A  A  A }
> >
> > - A  A  A  mapping = file->f_mapping;
> > - A  A  A  if (!mapping || len < 0) {
> > + A  A  A  if (len < 0) {
> 
> Current code makes sure mapping is valid after the above check,

Right.  I moved the !mapping check down a few lines.

> > A  A  A  A  A  A  A  A ret = -EINVAL;
> > A  A  A  A  A  A  A  A goto out;
> > A  A  A  A }

Now the check hits the "goto out" the get_xip_mem check hits:

> > - A  A  A  if (mapping->a_ops->get_xip_mem) {
> > + A  A  A  mapping = file->f_mapping;
> > + A  A  A  if (!mapping || mapping->a_ops->get_xip_mem) {
> > A  A  A  A  A  A  A  A switch (advice) {
> > A  A  A  A  A  A  A  A case POSIX_FADV_NORMAL:
> > A  A  A  A  A  A  A  A case POSIX_FADV_RANDOM:

		case POSIX_FADV_SEQUENTIAL:
		case POSIX_FADV_WILLNEED:
		case POSIX_FADV_NOREUSE:
		case POSIX_FADV_DONTNEED:
			/* no bad return value, but ignore advice */
			break;
		default:
			ret = -EINVAL;
		}
		goto out; <------ we hit this if (mapping == NULL)
	}

> but backing devices info is no longer evaluated with that
> guarantee in your change.
> 
> -hd
> 
> 75:	bdi = mapping->backing_dev_info;

The above line still doesn't evaluated because of the goto.

out:
	fput(file);
	return ret;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
