From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 3/3] mm/map_contig: Add mmap(MAP_CONTIG) support
Date: Mon, 16 Oct 2017 12:53:41 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1710161250470.13473@nuc-kabylake>
References: <20171013084054.me3kxhgbxzgm2lpr@dhcp22.suse.cz> <alpine.DEB.2.20.1710131015420.3949@nuc-kabylake> <20171013152801.nbpk6nluotgbmfrs@dhcp22.suse.cz> <alpine.DEB.2.20.1710131040570.4247@nuc-kabylake> <20171013154747.2jv7rtfqyyagiodn@dhcp22.suse.cz>
 <20171015065856.GC3916@xo-6d-61-c0.localdomain> <20171016081804.yiqck2g4bwlbdqi6@dhcp22.suse.cz> <20171016095447.GA4639@amd> <20171016121808.m4sq3g5nxeyxoymc@dhcp22.suse.cz> <alpine.DEB.2.20.1710161101310.12436@nuc-kabylake>
 <20171016173358.t3twty3wttbutcro@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171016173358.t3twty3wttbutcro@dhcp22.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
To: Michal Hocko <mhocko@kernel.org>
Cc: Pavel Machek <pavel@ucw.cz>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>
List-Id: linux-mm.kvack.org

On Mon, 16 Oct 2017, Michal Hocko wrote:

> On Mon 16-10-17 11:02:24, Cristopher Lameter wrote:
> > On Mon, 16 Oct 2017, Michal Hocko wrote:
> >
> > > > So I mmap(MAP_CONTIG) 1GB working of working memory, prefer some data
> > > > structures there, maybe recieve from network, then decide to write
> > > > some and not write some other.
> > >
> > > Why would you want this?
> >
> > Because we are receiving a 1GB block of data and then wan to write it to
> > disk. Maybe we want to modify things a bit and may not write all that we
> > received.
>
> And why do you need that in a single contiguous numbers? If performance,
> do you have any numbers that would clearly tell the difference?

Again we have that in the presentation. Why keep asking the same question
if you already have the answer multiple times?

1G of data requires 250000 page structs to handle if the memory is not
contiguous. This is more than most controllers can support and thus the
overhead will dominate I/O. Also the scatter gather lists will cover lots
of linked 4k pages even to manage.

And in practice we already have multiple gigabytes per requests which
makes it even more severe. You cannot do a "cp" operation anymore. Instead
you need to have special code that allocates huge pages, does direct I/O
etc etc,
