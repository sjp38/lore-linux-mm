Date: Tue, 25 Jan 2005 11:50:14 -0700
From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [PATCH] Avoiding fragmentation through different allocator
Message-ID: <20050125185014.GA3582@colo.lackof.org>
References: <0E3FA95632D6D047BA649F95DAB60E5705A70E61@exa-atlanta>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0E3FA95632D6D047BA649F95DAB60E5705A70E61@exa-atlanta>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Mukker, Atul" <Atulm@lsil.com>
Cc: 'Andi Kleen' <ak@muc.de>, 'Steve Lord' <lord@xfs.org>, 'Marcelo Tosatti' <marcelo.tosatti@cyclades.com>, 'Mel Gorman' <mel@csn.ul.ie>, 'William Lee Irwin III' <wli@holomorphy.com>, 'Linux Memory Management List' <linux-mm@kvack.org>, 'Linux Kernel' <linux-kernel@vger.kernel.org>, 'Grant Grundler' <grundler@parisc-linux.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 25, 2005 at 09:02:34AM -0500, Mukker, Atul wrote:
> The megaraid driver is open source, do you see anything that driver can do
> to improve performance. We would greatly appreciate any feedback in this
> regard and definitely incorporate in the driver. The FW under Linux and
> windows is same, so I do not see how the megaraid stack should perform
> differently under Linux and windows?

Just to second what Andy already stated: it's more likely the
Megaraid firmware could be better at fetching the SG lists.
This is a difficult problem since the firmware needs to work
well on so many different platforms/chipsets.

If LSI has time to turn more stones, get a PCI bus analyzer and filter
it to only capture CPU MMIO traffic and DMA traffic to/from some
"well known" SG lists (ie instrument the driver to print those to
the console). Then run AIM7 or similar multithreaded workload.
A perfect PCI trace will show the device pulling the SG list in
cacheline at time after the CPU MMIO reads/writes from the card
to indicate a new transaction is ready to go.

Another stone LSI could turn is to verify the megaraid controller is
NOT contending with the CPU for cachelines used to build SG lists.
This something the driver controls but I only know how to measure
this on ia64 machines (with pfmon or caliper or similar tool).
If you want examples, see
	http://iou.parisc-linux.org/ols2004/pfmon_for_iodorks.pdf

In case it's not clear from above, optimal IO flow means the device
is moving control data and streaming data in cacheline or bigger units.
If Megaraid is already doing that, then the PCI trace timing info
should point at where the latencies are.

hth,
grant
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
