Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1B9436B006E
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 21:51:27 -0400 (EDT)
Received: by ywa17 with SMTP id 17so10046423ywa.14
        for <linux-mm@kvack.org>; Tue, 01 Nov 2011 18:51:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALCETrVKHyRtizmTs=4hZzOs+7JLnvv0WtkSLYLDmM0fs2ce-w@mail.gmail.com>
References: <CALCETrXbPWsgaZmsvHZGEX-CxB579tG+zusXiYhR-13RcEnGvQ@mail.gmail.com>
 <ACE78D84-0E94-4E7A-99BF-C20583018697@dilger.ca> <CALCETrU23vyCXPG6mJU9qaPeAGOWDQtur5C+LRT154V5FM=Ajg@mail.gmail.com>
 <CALCETrX=-CnNQ9+4tRbqMG4mfuy2FBPXXoJeBVDVPnEiRJYRFQ@mail.gmail.com>
 <CALCETrUcOKQAJTTmCSD3Q3wYS-zLqv6tBa4AdkK50bNobRhDUQ@mail.gmail.com>
 <20111025122618.GA8072@quack.suse.cz> <CALCETrWoZeFpznU5Nv=+PvL9QRkTnS4atiGXx0jqZP_E3TJPqw@mail.gmail.com>
 <20111031231031.GD10107@quack.suse.cz> <CALCETrViG6t1forOFtO-R=bGABvtLcECxJ8m8Tenv6rwxLg_ew@mail.gmail.com>
 <20111101230320.GH18701@quack.suse.cz> <CALCETrVKHyRtizmTs=4hZzOs+7JLnvv0WtkSLYLDmM0fs2ce-w@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 1 Nov 2011 18:51:04 -0700
Message-ID: <CALCETrWNCy0VN-rQM-xPksiJ50DW-KM+w2NBprNOPhvnizZW=Q@mail.gmail.com>
Subject: Re: Latency writing to an mlocked ext4 mapping
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andreas Dilger <adilger@dilger.ca>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>

On Tue, Nov 1, 2011 at 4:10 PM, Andy Lutomirski <luto@amacapital.net> wrote=
:
> On Tue, Nov 1, 2011 at 4:03 PM, Jan Kara <jack@suse.cz> wrote:

>>
>> Avoiding IO during a minor fault would be a decent thing which might be
>> worth pursuing. As you properly noted "stable pages during writeback"
>> requirement is one obstacle which won't be that trivial to avoid though.=
..
>
> There's an easy solution that would be good enough for me: add a mount
> option to turn off stable pages.
>
> Is the other problem just a race, perhaps? =A0__block_page_mkwrite calls
> __block_write_begin (which calls get_block, which I think is where the
> latency comes from) *before* wait_on_page_writeback, which means that
> there might not be any space allocated yet.

I think I'm right (other than calling it a race).  If I change my code to d=
o:

- map the file (with MCL_FUTURE set)
- fallocate
- dirty all pages
- fsync
- dirty all pages again

in the non-real-time thread, then a short test that was a mediocre
reproducer seems to work.

This is annoying, though -- I'm not generating twice as much write I/O
as I used to.  Is there any way to force the delalloc code to do its
thing without triggering writeback?  I don't think fallocate has this
effect.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
