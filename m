Date: Fri, 6 Apr 2007 10:16:33 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: RE: [PATCH 4/4] IA64: SPARSE_VIRTUAL 16M page size support
In-Reply-To: <617E1C2C70743745A92448908E030B2A0153594A@scsmsx411.amr.corp.intel.com>
Message-ID: <Pine.LNX.4.64.0704061004140.25652@schroedinger.engr.sgi.com>
References: <617E1C2C70743745A92448908E030B2A0153594A@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: akpm@linux-foundation.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Dave Hansen <hansendc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 5 Apr 2007, Luck, Tony wrote:

> > This implements granule page sized vmemmap support for IA64.
> 
> Christoph,
> 
> Your calculations here are all based on a granule size of 16M, but
> it is possible to configure 64M granules.

Hmm...... Maybe we need to have a separate size for the vmemmap size?

> With current sizeof(struct page) == 56, a 16M page will hold enough
> page structures for about 4.5G of physical space (assuming 16K pages),
> so a 64M page would cover 18G.

Yes that is far too much.

> Maybe a granule is not the right unit of allocation ... perhaps 4M
> would work better (4M/56 ~= 75000 pages ~= 1.1G)?  But if this is
> too small, then a hard-coded 16M would be better than a granule,
> because 64M is (IMHO) too big.

I have some measurements 1M vs. 16M that I took last year when I first 
developed the approach:

1. 16k vmm page size

Tasks    jobs/min  jti  jobs/min/task      real       cpu
    1     2434.08  100      2434.0771      2.46      0.02   Thu Oct 12 03:22:20 2006
  100   178784.27   93      1787.8427      3.36      7.14   Thu Oct 12 03:22:34 2006
  200   279199.63   94      1395.9981      4.30     14.70   Thu Oct 12 03:22:52 2006
  300   340909.09   92      1136.3636      5.28     22.55   Thu Oct 12 03:23:14 2006
  400   381133.87   90       952.8347      6.30     30.64   Thu Oct 12 03:23:40 2006
  500   408942.20   93       817.8844      7.34     38.90   Thu Oct 12 03:24:10 2006
  600   430673.53   89       717.7892      8.36     47.15   Thu Oct 12 03:24:45 2006
  700   445859.87   92       636.9427      9.42     55.59   Thu Oct 12 03:25:23 2006
  800   460564.19   94       575.7052     10.42     63.57   Thu Oct 12 03:26:06 2006

2. 1M vmm page size

Tasks    jobs/min  jti  jobs/min/task      real       cpu
    1     2435.06  100      2435.0649      2.46      0.02   Thu Oct 12 03:08:25 2006
  100   178041.54   93      1780.4154      3.37      7.18   Thu Oct 12 03:08:39 2006
  200   278035.22   96      1390.1761      4.32     14.85   Thu Oct 12 03:08:57 2006
  300   338536.77   96      1128.4559      5.32     22.90   Thu Oct 12 03:09:19 2006
  400   377180.58   89       942.9514      6.36     31.19   Thu Oct 12 03:09:46 2006
  500   407000.41   96       814.0008      7.37     39.21   Thu Oct 12 03:10:16 2006
  600   428979.98   91       714.9666      8.39     47.43   Thu Oct 12 03:10:51 2006
  700   444209.41   94       634.5849      9.46     55.86   Thu Oct 12 03:11:30 2006
  800   455753.89   93       569.6924     10.53     64.59   Thu Oct 12 03:12:13 2006

4M would be right in the middle and maybe not so bad.

Note that these numbers were based on a more complex TLB handler.
See http://marc.info/?l=linux-ia64&m=116069969308257&w=2 (variable
kernel page size handler).

The problem with a different page size is that this would require 
redesign of the TLB lookup logic. We could go back to my variable kernel 
page size patch quoted above but then we walk the complete page table.

The 1 level lookup as far as I can tell only works well with 16M.

If we would try to use a 1 level lookup for a 4M page then we would have
a linear lookup table that takes up 4MB to support 1 Petabyte.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
