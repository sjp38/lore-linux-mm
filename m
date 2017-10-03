Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 707156B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 13:29:26 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id f202so6383960ioe.22
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 10:29:26 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 30sor2634613oto.523.2017.10.03.10.29.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Oct 2017 10:29:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171003080901.GD11879@quack2.suse.cz>
References: <150664806143.36094.11882924009668860273.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150664807800.36094.3685385297224300424.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171003080901.GD11879@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 3 Oct 2017 10:29:24 -0700
Message-ID: <CAPcyv4hOwKRMJ15GnPt7Qdtx2NiJQd-e8ooFc6SSQ=hoA58oUw@mail.gmail.com>
Subject: Re: [PATCH v2 3/4] dax: stop using VM_MIXEDMAP for dax
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Oct 3, 2017 at 1:09 AM, Jan Kara <jack@suse.cz> wrote:
> On Thu 28-09-17 18:21:18, Dan Williams wrote:
>> VM_MIXEDMAP is used by dax to direct mm paths like vm_normal_page() that
>> the memory page it is dealing with is not typical memory from the linear
>> map. The get_user_pages_fast() path, since it does not resolve the vma,
>> is already using {pte,pmd}_devmap() as a stand-in for VM_MIXEDMAP, so we
>> use that as a VM_MIXEDMAP replacement in some locations. In the cases
>> where there is no pte to consult we fallback to using vma_is_dax() to
>> detect the VM_MIXEDMAP special case.
>
> Well, I somewhat dislike the vma_is_dax() checks sprinkled around. That
> seems rather errorprone (easy to forget about it when adding new check
> somewhere). Can we possibly also create a helper vma_is_special() (or some
> other name) which would do ((vma->vm_flags & VM_SPECIAL) || vma_is_dax(vma)
> || is_vm_hugetlb_page(vma)) and then use it in all those places?

Yes, I can take a look at that... I shied away from it initially since
it does not appear that "vma_is_special()" paths are symmetric in
terms of all the conditions they check, but perhaps I can start small
with the ones that are common. I'll break that conversion out into a
lead-in cleanup patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
