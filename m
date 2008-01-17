Received: by wa-out-1112.google.com with SMTP id m33so1073843wag.8
        for <linux-mm@kvack.org>; Thu, 17 Jan 2008 05:34:23 -0800 (PST)
Message-ID: <4df4ef0c0801170534w3b019a07g1e1f493d76350e3d@mail.gmail.com>
Date: Thu, 17 Jan 2008 16:34:22 +0300
From: "Anton Salikhmetov" <salikhmetov@gmail.com>
Subject: Re: [PATCH -v5 2/2] Updating ctime and mtime at syncing
In-Reply-To: <20080117132429.GB14692@bitwizard.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <12005314662518-git-send-email-salikhmetov@gmail.com>
	 <1200531471556-git-send-email-salikhmetov@gmail.com>
	 <E1JFSgG-0006G1-6V@pomaz-ex.szeredi.hu>
	 <4df4ef0c0801170416s5581ae28h90d91578baa77738@mail.gmail.com>
	 <E1JFU7r-0006PK-So@pomaz-ex.szeredi.hu>
	 <4df4ef0c0801170516k3f82dc69ieee836b5633378a@mail.gmail.com>
	 <20080117132429.GB14692@bitwizard.nl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rogier Wolff <R.E.Wolff@bitwizard.nl>
Cc: Miklos Szeredi <miklos@szeredi.hu>, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

2008/1/17, Rogier Wolff <R.E.Wolff@bitwizard.nl>:
> On Thu, Jan 17, 2008 at 04:16:47PM +0300, Anton Salikhmetov wrote:
> > 2008/1/17, Miklos Szeredi <miklos@szeredi.hu>:
> > > > > 4. Recording the time was the file data changed
> > > > >
> > > > > Finally, I noticed yet another issue with the previous version of my patch.
> > > > > Specifically, the time stamps were set to the current time of the moment
> > > > > when syncing but not the write reference was being done. This led to the
> > > > > following adverse effect on my development system:
> > > > >
> > > > > 1) a text file A was updated by process B;
> > > > > 2) process B exits without calling any of the *sync() functions;
> > > > > 3) vi editor opens the file A;
> > > > > 4) file data synced, file times updated;
> > > > > 5) vi is confused by "thinking" that the file was changed after 3).
> > >
> > > Updating the time in remove_vma() would fix this, no?
> >
> > We need to save modification time. Otherwise, updating time stamps
> > will be confusing the vi editor.
>
> If process B exits before vi opens the file, the timestamp should at
> the latest be the time that process B exits. There is no excuse for
> setting the timestamp later than the time that B exits.
>
> If process B no longer modifies the file, but still keeps it mapped
> until after vi starts, then the system can't help the
> situation. Wether or not B acesses those pages is unknown to the
> system. So you get what you deserve.

The exit() system call closes the file memory-mapped file. Therefore,
it's better to catch the close() system call. However, the close() system call
does not trigger unmapping the file. The mapped area for the file may be
used after closing the file. So, we should catch only the unmap() call,
not close() or exit().

>
>         Roger.
>
> --
> ** R.E.Wolff@BitWizard.nl ** http://www.BitWizard.nl/ ** +31-15-2600998 **
> **    Delftechpark 26 2628 XH  Delft, The Netherlands. KVK: 27239233    **
> *-- BitWizard writes Linux device drivers for any device you may have! --*
> Q: It doesn't work. A: Look buddy, doesn't work is an ambiguous statement.
> Does it sit on the couch all day? Is it unemployed? Please be specific!
> Define 'it' and what it isn't doing. --------- Adapted from lxrbot FAQ
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
