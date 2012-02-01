Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id BB77E6B13F0
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 09:49:19 -0500 (EST)
References: <1327310360.96918.YahooMailNeo@web162003.mail.bf1.yahoo.com> <1327313719.76517.YahooMailNeo@web162002.mail.bf1.yahoo.com> <alpine.LSU.2.00.1201231125200.1677@eggly.anvils> <1327468926.52380.YahooMailNeo@web162002.mail.bf1.yahoo.com> <alpine.LSU.2.00.1201251623340.2141@eggly.anvils> <1327912964.12941.YahooMailNeo@web162006.mail.bf1.yahoo.com> <alpine.LSU.2.00.1201301034100.1884@eggly.anvils>
Message-ID: <1328107758.5077.YahooMailNeo@web162002.mail.bf1.yahoo.com>
Date: Wed, 1 Feb 2012 06:49:18 -0800 (PST)
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Reply-To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Subject: Re: [Help] : RSS/PSS showing 0 during smaps for Xorg
In-Reply-To: <alpine.LSU.2.00.1201301034100.1884@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Dear Hugh,=0A=A0=0AThank you for your help/suggestion so far.=0A=A0=0APleas=
e find further updates on this below.=0A=A0=0A>Sounds like you're not using=
 vm_insert_page() properly: I would not expect=0A>you to get a page fault t=
here once you've set up the area with a loop of=0A>vm_insert_page()s.=0A>pe=
rhaps you're mapping less than you need to.=0A=0A1)=A0 The page fault is no=
t occuring now after calling vm_insert_page() in a loop for every page. The=
 hint about "mapping less than you need to" stricked me. Please check the s=
napshot below.=0A=A0=A0=A0=A0 loop=0A=A0=A0=A0=A0=A0=A0=A0=A0vm_insert_page=
(vma,start,page);=0A=A0=A0=A0=A0=A0=A0=A0=A0start =3D start + PAGE_SIZE;=0A=
=A0=A0=A0=A0=A0=A0=A0=A0size =3D size - PAGE_SIZE;=0A=A0=A0=A0=A0until size=
 > 0=0A=A0=0A=A0=A0=A0=A0I verified other drivers in kernel code and found =
this is how it is done.=0A=A0=0A2)=A0 But after doing all this also my menu=
-screen is not proper. Still I am getting colorful lines on the menu-screen=
.=0A=A0=A0=A0=A0 Can you point me out what could be the problem??=0A=A0=0A=
=A0=0A=A0=0AThanks, Regards,=0APintu=0A=A0=0A=A0=0A>_______________________=
_________=0A>From: Hugh Dickins <hughd@google.com>=0A>To: PINTU KUMAR <pint=
u_agarwal@yahoo.com> =0A>Cc: "linux-kernel@vger.kernel.org" <linux-kernel@v=
ger.kernel.org>; "linux-mm@kvack.org" <linux-mm@kvack.org> =0A>Sent: Tuesda=
y, 31 January 2012 12:19 AM=0A>Subject: Re: [Help] : RSS/PSS showing 0 duri=
ng smaps for Xorg=0A>=0A>On Mon, 30 Jan 2012, PINTU KUMAR wrote:=0A>> =A0=
=0A>> >If these are ordinary pages with struct pages, then you could probab=
ly=0A>> >use a loop of vm_insert_page()s to insert them at mmap time, or a =
fault=0A>> >routine to insert them on fault.=A0 But as I said, I don't know=
 if this=0A>> >memory is part of the ordinary page pool or not.=0A>> =A0=0A=
>> You suggestion about using vm_insert_page() instead of remap_pfn_range w=
orked for me and I got the Rss/Pss information for my driver.=0A>=0A>Oh, I'=
m glad that happened to work for you.=0A>=0A>> But still there is one probl=
em related to page fault. =0A>> If I remove remap_pfn_range then I get a pa=
ge fault in the beginning. =0A>> I tried to use the same vm_insert_page() d=
uring page_fault_handler for each vmf->virtual_address but it did not work.=
=0A>> So for time being I remove the page fault handler from my vm_operatio=
ns.=0A>> But with these my menu screen(LCD screen) is not behaving properly=
 (I get colorful lines on my LCD).=0A>> So I need to handle the page fault =
properly.=0A>> =A0=0A>> But I am not sure what is that I need to do inside =
page fault handler. Do you have any example or references or suggestions?=
=0A>=0A>Sounds like you're not using vm_insert_page() properly: I would not=
 expect=0A>you to get a page fault there once you've set up the area with a=
 loop of=0A>vm_insert_page()s.=0A>=0A>Check the comments above it in mm/mem=
ory.c ("Your vma protection will=0A>have to be set up correctly" might be r=
elevant).=0A>=0A>Compare how you're using it with other users of vm_insert_=
page() in=0A>the kernel tree.=A0 Sorry, I don't have time to do your debugg=
ing.=0A>=0A>> =A0=0A>> >Really, the question has to be, why do you need to =
see non-0s there?=0A>> I want Rss/Pss value to account for how much video m=
emory is used by the driver for the menu-screen,Xorg processes.=0A>=0A>So, =
userspace does an mmap for a large-enough window, but only some part of=0A>=
that is filled by the driver (whether by remap_pfn_range or vm_insert_pages=
),=0A>and you'd like to communicate back how much via the Rss, instead of a=
dding=0A>some ioctl or sysfs interface to the driver?=A0 Fair enough.=0A>=
=0A>I expect userspace could also work it out by touching pages of the area=
=0A>until it gets a SIGBUS, but that might be too dirty a way of finding ou=
t.=0A>=0A>Hmm, SIGBUS: maybe that's related to the faults that are puzzling=
 you:=0A>perhaps you're mapping less than you need to.=0A>=0A>Hugh=0A>=0A>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
