Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id B83FE6B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 10:49:45 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so39541663pab.7
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 07:49:45 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTP id kt6si839763pbc.47.2015.01.19.07.49.43
        for <linux-mm@kvack.org>;
        Mon, 19 Jan 2015 07:49:44 -0800 (PST)
Message-ID: <1421682581.2080.22.camel@HansenPartnership.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] async buffered diskio read for
 userspace apps
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Mon, 19 Jan 2015 07:49:41 -0800
In-Reply-To: <54BD234F.3060203@kernel.dk>
References: 
	<CANP1eJF77=iH_tm1y0CgF6PwfhUK6WqU9S92d0xAnCt=WhZVfQ@mail.gmail.com>
		<20150115223157.GB25884@quack.suse.cz>
		<CANP1eJGRX4w56Ek4j7d2U+F7GNWp6RyOJonxKxTy0phUCpBM9g@mail.gmail.com>
		<20150116165506.GA10856@samba2>
		<CANP1eJEF33gndXeBJ0duP2_Bvuv-z6k7OLyuai7vjVdVKRYUWw@mail.gmail.com>
		<20150119071218.GA9747@jeremy-HP>
		<1421652849.2080.20.camel@HansenPartnership.com>
	 <CANP1eJHYUprjvO1o6wfd197LM=Bmhi55YfdGQkPT0DKRn3=q6A@mail.gmail.com>
	 <54BD234F.3060203@kernel.dk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Milosz Tanski <milosz@adfin.com>, Volker Lendecke <Volker.Lendecke@sernet.de>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, lsf-pc@lists.linux-foundation.org, Jeremy Allison <jra@samba.org>

On Mon, 2015-01-19 at 08:31 -0700, Jens Axboe wrote:
> On 01/19/2015 07:18 AM, Milosz Tanski wrote:
> > On Mon, Jan 19, 2015 at 2:34 AM, James Bottomley
> > <James.Bottomley@hansenpartnership.com> wrote:
> >> On Sun, 2015-01-18 at 23:12 -0800, Jeremy Allison wrote:
> >>> On Sun, Jan 18, 2015 at 10:49:36PM -0500, Milosz Tanski wrote:
> >>>>
> >>>> I have the first version of the FIO cifs support via samba in my fork
> >>>> of FIO here: https://github.com/mtanski/fio/tree/samba
> >>>>
> >>>> Right now it only supports sync mode of FIO (eg. can't submit multiple
> >>>> outstanding requests) but I'm looking into how to make it work with
> >>>> smb2 read/write calls with the async flag.
> >>>>
> >>>> Additionally, I'm sure I'm doing some things not quite right in terms
> >>>> of smbcli usage as it was a decent amount of trial and error to get it
> >>>> to connect (esp. the setup before smbcli_full_connection). Finally, it
> >>>> looks like the more complex api I'm using (as opposed to smbclient,
> >>>> because I want the async calls) doesn't quite fully export all calls I
> >>>> need via headers / public dyn libs so it's a bit of a hack to get it
> >>>> to build: https://github.com/mtanski/fio/commit/7fd35359259b409ed023b924cb2758e9efb9950c#diff-1
> >>>>
> >>>> But it works for my randread tests with zipf and the great part is
> >>>> that it should provide a flexible way to test samba with many fake
> >>>> clients and access patterns. So... progress.
> >>>
> >>> One problem here. Looks like fio is under GPLv2-only,
> >>> is that correct ?
> >>
> >> Seems so from the LICENSE file.
> >>
> >>> If so there's no way to combine the two codebases,
> >>> as Samba is under GPLv3-or-later with parts under LGPLv3-or-later.
> >>>
> >>> fio needs to be GPLv2-or-later in order to be
> >>> able to use with libsmbclient.
> >>
> >> That's one of these pointless licensing complexities that annoy
> >> distributions so much ... they're both open source, so there's no real
> >> problem except the licence incompatibility. The usual way out of it is
> >> just to dual licence the incompatible component.
> >>
> >> James
> >>
> >>
> >
> > Sadly, in this case there's nothing I can do about the license; both
> > projects have a right to determine their own licensing. Hopefully, the
> > parties can come to some kind of agreement since it would be
> > beneficial to use fio to test samba.
> >
> > This works well enough for me to test test preadv2 using samba and get
> > numbers. So I'll use this to do some preadv2 testing using samba for
> > different workloads.
> 
> I didn't look at your code yet, but I'm assuming it's a self contained 
> IO engine. So we should be able to make that work, by only linking the 
> engine itself against libsmbclient. But sheesh, what a pain in the butt, 
> why can't we just all be friends.
> 
> So don't worry about licensing for now, just work on improving the 
> engine and we'll sort the non-technical details out.

For fio, it likely doesn't matter.  Most people download the repository
and compile it themselves when building the tool. In that case, there's
no licence violation anyway (all GPL issues, including technical licence
incompatibility, manifest on distribution not on use).  It is a problem
for the distributors, but they're well used to these type of self
inflicted wounds.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
