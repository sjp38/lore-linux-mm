Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id BC2536B004D
	for <linux-mm@kvack.org>; Thu, 19 Nov 2009 22:41:03 -0500 (EST)
Received: by iwn34 with SMTP id 34so2157050iwn.12
        for <linux-mm@kvack.org>; Thu, 19 Nov 2009 19:41:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091118221756.367c005e@ustc>
References: <2df346410911151938r1eb5c5e4q9930ac179d61ef01@mail.gmail.com>
	 <20091117015655.GA8683@suse.de> <20091117123622.GI27677@think>
	 <20091117190635.GB31105@duck.suse.cz> <20091118221756.367c005e@ustc>
Date: Fri, 20 Nov 2009 11:41:02 +0800
Message-ID: <2df346410911191941w6f540563u78a1a5f9ba989b6d@mail.gmail.com>
Subject: Re: [BUG]2.6.27.y some contents lost after writing to mmaped file
From: JiSheng Zhang <jszhang3@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Chris Mason <chris.mason@oracle.com>, Greg KH <gregkh@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org, rmk@arm.linux.org.uk, linux-arm@lists.infradead.org
List-ID: <linux-mm.kvack.org>

Hi,

Russell King wrote
>- CPU type
ARM926EJ-S
>- is it a SMP CPU
no. UP
>- are you running a SMP kernel
no
>- board type
an soc


>- the storage peripheral being used for this test
memory and harddrive
>- is DMA being used for this periperal
for memory, DMA? for harddrive, yes
>- any additional block layers (eg, lvm, dm, md)
no
>- filesystem type
tmpfs and ext3

2009/11/18 JiSheng Zhang <jszhang3@gmail.com>:
> On Tue, 17 Nov 2009 20:06:35 +0100
> Jan Kara <jack@suse.cz> wrote:
>
>> On Tue 17-11-09 07:36:22, Chris Mason wrote:
>> > On Mon, Nov 16, 2009 at 05:56:55PM -0800, Greg KH wrote:
>> > > On Mon, Nov 16, 2009 at 11:38:57AM +0800, JiSheng Zhang wrote:
>> > > > Hi,
>> > > >
>> > > > I triggered a failure in an fs test with fsx-linux from ltp. It se=
ems that
>> > > > fsx-linux failed at mmap->write sequence.
>> > > >
>> > > > Tested kernel is 2.6.27.12 and 2.6.27.39
>> > >
>> > > Does this work on any kernel you have tested? =A0Or is it a regressi=
on?
>> > >
>> > > > Tested file system: ext3, tmpfs.
>> > > > IMHO, it impacts all file systems.
>> > > >
>> > > > Some fsx-linux log is:
>> > > >
>> > > > READ BAD DATA: offset =3D 0x2771b, size =3D 0xa28e
>> > > > OFFSET =A0GOOD =A0 =A0BAD =A0 =A0 RANGE
>> > > > 0x287e0 0x35c9 =A00x15a9 =A0 =A0 0x80
>> > > > operation# (mod 256) for the bad datamay be 21
>> > > > ...
>> > > > 7828: 1257514978.306753 READ =A0 =A0 0x23dba thru 0x25699 (0x18e0 =
bytes)
>> > > > 7829: 1257514978.306899 MAPWRITE 0x27eeb thru 0x2a516 (0x262c byte=
s)
>> > > > =A0******WWWW
>> > > > 7830: 1257514978.307504 READ =A0 =A0 0x2771b thru 0x319a8 (0xa28e =
bytes)
>> > > > =A0***RRRR***
>> > > > Correct content saved for comparison
>> > > > ...
>> =A0 Hmm, how long does it take to reproduce? I'm running fsx-linux on tm=
pfs
>> for a while on 2.6.27.21 and didn't hit the problem yet.
>
> I forget to mention that the test were done on an arm board with 64M ram.
> I have tested fsx-linux again on pc, it seems that failure go away.
>
>>
>> > > Are you sure that the LTP is correct? =A0It wouldn't be the first ti=
me it
>> > > wasn't...
>> >
>> > I'm afraid fsx usually finds bugs. =A0I thought Jan Kara recently fixe=
d
>> > something here in ext3, does 2.6.32-rc work?
>> =A0 Yeah, fsx usually finds bugs. Note that he sees the problem also on =
tmpfs
>> so it's not ext3 problem. Anyway, trying to reproduce with 2.6.32-rc? wo=
uld
>> be interesting.
>
> Currently the arm board doesn't support 2.6.32-rc. But I test with 2.6.32=
-rc7
> On my pc box, there's no failure so far.
>
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Honza
>
> I found this via google:
> http://marc.info/?t=3D118026315000001&r=3D1&w=3D2
>
> I even tried the code from
> http://marc.info/?l=3Dlinux-arch&m=3D118030601701617&w=3D2
> I got mostly:
> firstfirstfirst
> firstfirstfirst
> firstfirstfirst
>
>
> No change after pass "MS_SYNC|MS_INVALIDATE" to msync and make the
> flush_dcache_page() call unconditional in do_generic_mapping_read.
> This behavior is different from what I read from the mail thread above.
>
>> void do_generic_mapping_read(struct address_space *mapping,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct file_r=
a_state *_ra,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct file *=
filp,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0loff_t *ppos,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0read_descript=
or_t *desc,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0read_actor_t =
actor)
>> {
>> ...
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* If users can be writing to this page =
using arbitrary
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* virtual addresses, take care about =
potential aliasing
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* before reading the page on the kern=
el side.
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (1 || mapping_writably_mapped(mapping=
))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 flush_dcache_page(page);
>
> Then I run fsx-linux after the above modification, fsx-linux failed all
> the same both on tmpfs and ext3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
