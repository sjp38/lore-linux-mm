Date: Sun, 13 Oct 2002 19:43:41 +0300 (EEST)
From: Kai Makisara <Kai.Makisara@kolumbus.fi>
Subject: Re: 2.5.42-mm2
In-Reply-To: <20021013125656.J7028@nightmaster.csn.tu-chemnitz.de>
Message-ID: <Pine.LNX.4.44.0210131919570.7451-100000@kai.makisara.local>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, Andrew Morton <akpm@digeo.com>
Cc: Douglas Gilbert <dougg@torque.net>, linux-scsi@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 13 Oct 2002, Ingo Oeser wrote:

> Hi Andrew,
>
> [I cc'ed the people relevant to this issue]
>
> On Sat, Oct 12, 2002 at 10:26:44AM -0700, Andrew Morton wrote:
> > Ingo Oeser wrote:
> > > Stupid question: Would you accept a patch that extends
> > > get_user_pages() to accept an additional "struct scatterlist vector[]"?
> >
> > It's not really my area Ingo.  But I can wave such a patch about
> > on the mailing lists, generally get it some review and attention
> > I guess.
>
> I had waved an example on what is really needed instead of kiobuf
> crap some time ago[1]. This raised a discussion on linux-scsi[2]
> (but I'm not subscribed there) and someone[2] actually successfully
> tested this.
>
> > Such nfrastructure would need something which used it, as a proof-of-concept,
> > testbed, etc...
>
> I would love to test my ideas out, but the special purpose device
> where I need it for has bit-errors on its big SDRAM chips and I can
> only use a small 32K area of storage for testing, which is not
> expected to reveal any noticable performance from that method,
> due to the high setup overhead. I think you know the numbers from
> direct-io.
>
> The video hardware, where you (or Geert?) basically implemented
> the things, we proposed[3] would be a perfect testbed for this.
>
The SCSI tape driver has used an approach nearly similar to [3] from
2.5.32. The same applies to Doug Gilbert's the generic SCSI driver. The
mapping and unmapping functions are duplicated in st.c and sg.c. This is
meant to be a temporary solution until something useful appears elsewhere
in the kernel.

The st.c versions of the mapping and unmapping functions are almost same
as [3]:
- GFP_KERNEL is used instead of GFP_USER when allocating the page pointer
  buffer (is GFP_USER really correct in this case?)
- partial mappings are not accepted
- the unmapping functions marks pages dirty if told to do that
[3] is OK for st.c if it is the most versatile interface for other users.

The only problem so far has been with the sg driver in Doug's sgm_dd that
does direct write from a driver buffer mmapped to the user program (i.e.,
copies data using a buffer within the driver). Doug asked me to look at
the problem and try to find out if there is something wrong with an
approach like [3]. I inserted some printks into sg and found out that
get_user_pages() returned bogus page pointers in this case. I do not
understand vm enough to say where the problem is in this special case.

> Thanks & Regards
>
> Ingo Oeser
>
> [1] <20020720003918.G758@nightmaster.csn.tu-chemnitz.de> on lkml
> [2] <Pine.LNX.4.44.0207292045040.770-100000@kai.makisara.local> on linux-scsi
> [3] Attached here.
>

-- 
Kai





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
