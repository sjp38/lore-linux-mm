Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E48176B005A
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 19:20:25 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <ac5dec0d-e593-4a82-8c9d-8aa374e8c6ed@default>
Date: Wed, 8 Jul 2009 16:31:29 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [Xen-devel] Re: [RFC PATCH 0/4] (Take 2): transcendent memory
 ("tmem") for Linux
In-Reply-To: <4A55243B.8090001@codemonkey.ws>
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Anthony Liguori <anthony@codemonkey.ws>
Cc: npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, linux-kernel@vger.kernel.org, dave.mccracken@oracle.com, linux-mm@kvack.org, chris.mason@oracle.com, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, alan@lxorguk.ukuu.org.uk, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi Anthony --

Thanks for the comments.

> I have trouble mapping this to a VMM capable of overcommit=20
> without just coming back to CMM2.
>=20
> In CMM2 parlance, ephemeral tmem pools is just normal kernel memory=20
> marked in the volatile state, no?

They are similar in concept, but a volatile-marked kernel page
is still a kernel page, can be changed by a kernel (or user)
store instruction, and counts as part of the memory used
by the VM.  An ephemeral tmem page cannot be directly written
by a kernel (or user) store, can only be read via a "get" (which
may or may not succeed), and doesn't count against the memory
used by the VM (even though it likely contains -- for awhile --
data useful to the VM).

> It seems to me that an architecture built around hinting=20
> would be more=20
> robust than having to use separate memory pools for this type=20
> of memory=20
> (especially since you are requiring a copy to/from the pool).

Depends on what you mean by robust, I suppose.  Once you
understand the basics of tmem, it is very simple and this
is borne out in the low invasiveness of the Linux patch.
Simplicity is another form of robustness.

> For instance, you can mark data DMA'd from disk (perhaps by=20
> read-ahead)=20
> as volatile without ever bringing it into the CPU cache. =20
> With tmem, if=20
> you wanted to use a tmem pool for all of the page cache, you'd likely=20
> suffer significant overhead due to copying.

The copy may be expensive on an older machine, but on newer
machines copying a page is relatively inexpensive.  On a reasonable
multi-VM-kernbench-like benchmark I'll be presenting at Linux
Symposium next week, the overhead is on the order of 0.01%
for a fairly significant savings in IOs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
