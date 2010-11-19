Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D30106B0071
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 18:31:49 -0500 (EST)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id oAJNVigq009433
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 15:31:44 -0800
Received: from qyk7 (qyk7.prod.google.com [10.241.83.135])
	by wpaz17.hot.corp.google.com with ESMTP id oAJNVgUZ023911
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 15:31:43 -0800
Received: by qyk7 with SMTP id 7so21184qyk.0
        for <linux-mm@kvack.org>; Fri, 19 Nov 2010 15:31:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101119145442.ddf0c0e8.akpm@linux-foundation.org>
References: <1289996638-21439-1-git-send-email-walken@google.com>
	<1289996638-21439-4-git-send-email-walken@google.com>
	<20101117125756.GA5576@amd>
	<1290007734.2109.941.camel@laptop>
	<AANLkTim4tO_aKzXLXJm-N-iEQ9rNSa0=HGJVDAz33kY6@mail.gmail.com>
	<20101117231143.GQ22876@dastard>
	<20101118133702.GA18834@infradead.org>
	<alpine.LSU.2.00.1011180934400.3210@tigran.mtv.corp.google.com>
	<20101119072316.GA14388@google.com>
	<20101119145442.ddf0c0e8.akpm@linux-foundation.org>
Date: Fri, 19 Nov 2010 15:31:42 -0800
Message-ID: <AANLkTi=N=+hLd7bJZ87mgp0bGnyvT=43yQHBaDFZGTjY@mail.gmail.com>
Subject: Re: [PATCH 3/3] mlock: avoid dirtying pages and triggering writeback
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Theodore Tso <tytso@google.com>, Michael Rubin <mrubin@google.com>, Suleiman Souhlal <suleiman@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 19, 2010 at 2:54 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 18 Nov 2010 23:23:16 -0800
> Michel Lespinasse <walken@google.com> wrote:
>
>> On Thu, Nov 18, 2010 at 09:41:22AM -0800, Hugh Dickins wrote:
>> > On Thu, 18 Nov 2010, Christoph Hellwig wrote:
>> > > I think it would help if we could drink a bit of the test driven des=
ign
>> > > coolaid here. Michel, can you write some testcases where pages on a
>> > > shared mapping are mlocked, then dirtied and then munlocked, and the=
n
>> > > written out using msync/fsync. =A0Anything that fails this test on
>> > > btrfs/ext4/gfs/xfs/etc obviously doesn't work.
>> > Whilst it's hard to argue against a request for testing, Dave's worrie=
s
>> > just sprang from a misunderstanding of all the talk about "avoiding ->
>> > page_mkwrite". =A0There's nothing strange or risky about Michel's patc=
h,
>> > it does not avoid ->page_mkwrite when there is a write: it just stops
>> > pretending that there was a write when locking down the shared area.
>>
>> So, I decided to test this using memtoy.
>
> Wait. =A0You *tested* the kernel?
>
> I dunno, kids these days...

Not guilty - I mean, Christoph made me do it !

> Dirtying all that memory at mlock() time is pretty obnoxious.
>
> I'm inclined to agree that your patch implements the desirable
> behaviour: don't dirty the page, don't do block allocation. =A0Take a
> fault at first-dirtying and do it then. =A0This does degrade mlock a bit:
> the user will find that the first touch of an mlocked page can cause
> synchronous physical I/O, which isn't mlocky behaviour *at all*. =A0But
> we have to be able to do this anyway - whenever the kupdate function
> writes back the dirty pages it has to mark them read-only again so the
> kernel knows when they get redirtied.

Glad to see that we seem to be coming to an agreement here.

> So all that leaves me thinking that we merge your patches as-is. =A0Then
> work out why users can fairly trivially use mlock to hang the kernel on
> ext2 and ext3 (and others?)

I would say the hang is not even mlock related - you see without it
also. All you need is mmap a large file with holes and write fault
pages until you run out of disk space. At that point additional write
faults wait for a writeback that can never complete. Sysadmin can
however kill -9 such processes and/or free some space, though.

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
