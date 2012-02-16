Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 0C8786B00E8
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 10:14:12 -0500 (EST)
Received: by bkty12 with SMTP id y12so2706304bkt.14
        for <linux-mm@kvack.org>; Thu, 16 Feb 2012 07:14:11 -0800 (PST)
Date: Thu, 16 Feb 2012 16:14:25 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [PATCH] mm: extend prefault helpers to fault in more than
 PAGE_SIZE
Message-ID: <20120216151425.GB19158@phenom.ffwll.local>
References: <1329393696-4802-1-git-send-email-daniel.vetter@ffwll.ch>
 <1329393696-4802-2-git-send-email-daniel.vetter@ffwll.ch>
 <CAJd=RBBr4EkCwAaS3xZZrm0QE71Z0soyZXTuwXyBn6ohp3pU2Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAJd=RBBr4EkCwAaS3xZZrm0QE71Z0soyZXTuwXyBn6ohp3pU2Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>, Andrew Morton <akpm@linux-foundation.org>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Thu, Feb 16, 2012 at 09:32:08PM +0800, Hillf Danton wrote:
> On Thu, Feb 16, 2012 at 8:01 PM, Daniel Vetter <daniel.vetter@ffwll.ch> wrote:
> > @@ -416,17 +417,20 @@ static inline int fault_in_pages_writeable(char __user *uaddr, int size)
> >         * Writing zeroes into userspace here is OK, because we know that if
> >         * the zero gets there, we'll be overwriting it.
> >         */
> > -       ret = __put_user(0, uaddr);
> > +       while (uaddr <= end) {
> > +               ret = __put_user(0, uaddr);
> > +               if (ret != 0)
> > +                       return ret;
> > +               uaddr += PAGE_SIZE;
> > +       }
> 
> What if
>              uaddr & ~PAGE_MASK == PAGE_SIZE -3 &&
>                 end & ~PAGE_MASK == 2

I don't quite follow - can you elaborate upon which issue you're seeing?
-Daniel
-- 
Daniel Vetter
Mail: daniel@ffwll.ch
Mobile: +41 (0)79 365 57 48

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
