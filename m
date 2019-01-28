From: Jonathan Cameron <jonathan.cameron@huawei.com>
Subject: Re: [RFC][PATCH v2 00/21] PMEM NUMA node and hotness
 accounting/migration
Date: Mon, 28 Jan 2019 17:42:39 +0000
Message-ID: <20190128174239.0000636b@huawei.com>
References: <20181226131446.330864849@intel.com>
        <20181227203158.GO16738@dhcp22.suse.cz>
        <20181228050806.ewpxtwo3fpw7h3lq@wfg-t540p.sh.intel.com>
        <20181228084105.GQ16738@dhcp22.suse.cz>
        <20181228094208.7lgxhha34zpqu4db@wfg-t540p.sh.intel.com>
        <20181228121515.GS16738@dhcp22.suse.cz>
        <20181228133111.zromvopkfcg3m5oy@wfg-t540p.sh.intel.com>
        <20181228195224.GY16738@dhcp22.suse.cz>
        <20190102122110.00000206@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20190102122110.00000206@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Huang Ying <ying.huang@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, kvm@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Fan Du <fan.du@intel.com>, Dong Eddie <eddie.dong@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-accelerators@lists.ozlabs.org, Linux Memory Management List <linux-mm@kvack.org>, Peng Dong <dongx.peng@intel.com>, Yao Yuan <yuan.yao@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Dan Williams <dan.j.williams@intel.com>, Mel Gorman <mgorman@suse.de>
List-Id: linux-mm.kvack.org

On Wed, 2 Jan 2019 12:21:10 +0000
Jonathan Cameron <jonathan.cameron@huawei.com> wrote:

> On Fri, 28 Dec 2018 20:52:24 +0100
> Michal Hocko <mhocko@kernel.org> wrote:
> 
> > [Ccing Mel and Andrea]
> > 

Hi,

I just wanted to highlight this section as I didn't feel we really addressed this
in the earlier conversation.

> * Hot pages may not be hot just because the host is using them a lot.  It would be
>   very useful to have a means of adding information available from accelerators
>   beyond simple accessed bits (dreaming ;)  One problem here is translation
>   caches (ATCs) as they won't normally result in any updates to the page accessed
>   bits.  The arm SMMU v3 spec for example makes it clear (though it's kind of
>   obvious) that the ATS request is the only opportunity to update the accessed
>   bit.  The nasty option here would be to periodically flush the ATC to force
>   the access bit updates via repeats of the ATS request (ouch).
>   That option only works if the iommu supports updating the accessed flag
>   (optional on SMMU v3 for example).
> 

If we ignore the IOMMU hardware update issue which will simply need to be addressed
by future hardware if these techniques become common, how do we address the
Address Translation Cache issue without potentially causing big performance
problems by flushing the cache just to force an accessed bit update?

These devices are frequently used with PRI and Shared Virtual Addressing
and can be accessing most of your memory without you having any visibility
of it in the page tables (as they aren't walked if your ATC is well matched
in size to your usecase.

Classic example would be accelerated DB walkers like the the CCIX demo
Xilinx has shown at a few conferences.   The whole point of those is that
most of the time only your large set of database walkers is using your
memory and they have translations cached for for a good part of what
they are accessing.  Flushing that cache could hurt a lot.
Pinning pages hurts for all the normal flexibility reasons.

Last thing we want is to be migrating these pages that can be very hot but
in an invisible fashion.

Thanks,

Jonathan
 
