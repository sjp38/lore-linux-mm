Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 7200C6B0031
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 12:47:39 -0400 (EDT)
Message-ID: <51F2A81E.5050500@sr71.net>
Date: Fri, 26 Jul 2013 09:47:26 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/2] vmsplice unmap gifted pages for recipient
References: <1374772906-21511-1-git-send-email-rcj@linux.vnet.ibm.com> <1374772906-21511-2-git-send-email-rcj@linux.vnet.ibm.com> <51F160A5.2040004@sr71.net> <20130726151621.GA5037@linux.vnet.ibm.com>
In-Reply-To: <20130726151621.GA5037@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Matt Helsley <matt.helsley@gmail.com>, Anthony Liguori <aliguori@us.ibm.com>, Michael Roth <mdroth@linux.vnet.ibm.com>, Lei Li <lilei@linux.vnet.ibm.com>, Leonardo Garcia <lagarcia@linux.vnet.ibm.com>

On 07/26/2013 08:16 AM, Robert Jennings wrote:
>>> > > +				if ((spd->flags & SPLICE_F_MOVE) &&
>>> > > +				    !buf->offset && (buf->len == PAGE_SIZE))
>>> > > +					/* Can move page aligned buf */
>>> > > +					zap_buf_page(useraddr);
>>> > >  				buf->flags |= PIPE_BUF_FLAG_GIFT;
>>> > > +			}
>> > 
>> > There isn't quite enough context here, but is it going to do this
>> > zap_buf_page() very often?  Seems a bit wasteful to do the up/down and
>> > find_vma() every trip through the loop.
> The call to zap_buf_page() is in a loop where each pipe buffer is being
> processed, but in that loop we have a pipe_wait() where we schedule().
> So as things are structured I don't have the ability to hold mmap_sem
> for multiple find_vma() calls.

You can hold a semaphore over a schedule(). :)

You could also theoretically hold mmap_sem and only drop it on actual
cases when you reschedule if you were afraid of holding mmap_sem for
long periods of time (even though it's a read).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
