Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 432EA6B0259
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 10:26:22 -0400 (EDT)
Received: by iofz202 with SMTP id z202so92735079iof.2
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 07:26:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c72si11470757ioc.179.2015.10.22.07.26.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 07:26:21 -0700 (PDT)
Date: Thu, 22 Oct 2015 10:26:18 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH v11 07/14] HMM: mm add helper to update page table when
 migrating memory v2.
Message-ID: <20151022142618.GC2914@redhat.com>
References: <062101d10cae$91d986d0$b58c9470$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <062101d10cae$91d986d0$b58c9470$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu, Oct 22, 2015 at 05:46:47PM +0800, Hillf Danton wrote:
> > 
> > This is a multi-stage process, first we save and replace page table
> > entry with special HMM entry, also flushing tlb in the process. If
> > we run into non allocated entry we either use the zero page or we
> > allocate new page. For swaped entry we try to swap them in.
> > 
> Please elaborate why swap entry is handled this way.

So first, this is only when you have a device then use HMM and a device
that use memory migration. So far it only make sense for discrete GPUs.
So regular workload that do not use a GPUs with HMM are not impacted and
will not go throught this code path.

Now, here we are migrating memory because the device driver is asking for
it, so presumably we are expecting that the device will use that memory
hence we want to swap in anything that have been swap to disk. Once it is
swap in memory we copy it to device memory and free the pages. So in the
end we only need to allocate a page temporarily until we move things to
the device.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
