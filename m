Date: Tue, 21 Aug 2007 14:03:28 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 0/7] Postphone reclaim laundry to write at high water marks
In-Reply-To: <200708211051.36569.dave.mccracken@oracle.com>
Message-ID: <Pine.LNX.4.64.0708211400341.3082@schroedinger.engr.sgi.com>
References: <20070820215040.937296148@sgi.com> <200708211051.36569.dave.mccracken@oracle.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1700579579-1839598108-1187730208=:3082"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dave.mccracken@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

---1700579579-1839598108-1187730208=:3082
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Tue, 21 Aug 2007, Dave McCracken wrote:

> On Monday 20 August 2007, Christoph Lameter wrote:
> > 1. First reclaiming non dirty pages. Dirty pages are deferred until rec=
laim
> > =A0 =A0has reestablished the high marks. Then all the dirty pages (the =
laundry)
> > =A0 =A0is written out.
>=20
> I don't buy it.  What happens when there aren't enough clean pages in the=
=20
> system to achieve the high water mark?  I'm guessing we'd get a quick OOM=
 (as=20
> observed by Peter).

We reclaim the clean pages that there are (removing the executable=20
pages from memory) and then we do writeback.

The quick OOM is due to throttling not working right AFAIK.

> > 2. Reclaim is essentially complete during the writeout phase. So we rem=
ove
> > =A0 =A0PF_MEMALLOC and allow recursive reclaim if we still run into tro=
uble
> > =A0 =A0during writeout.
>=20
> You're assuming the system is static and won't allocate new pages behind =
your=20
> back.  We could be back to critically low memory before the write happens=
=2E

Yes and that occurs now too.

> More broadly, we need to be proactive about getting dirty pages cleaned b=
efore=20
> they consume the system.  Deferring the write just makes it harder to kee=
p=20
> up.

Cleaning dirty pages through writeout consumes memory. Writing dirty pages=
=20
out early makes the memory situation even worse.

---1700579579-1839598108-1187730208=:3082--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
