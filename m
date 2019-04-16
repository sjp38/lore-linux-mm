Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7414C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 06:51:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E2CC20675
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 06:51:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E2CC20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 949FC6B0003; Tue, 16 Apr 2019 02:51:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F9956B0006; Tue, 16 Apr 2019 02:51:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 811276B0007; Tue, 16 Apr 2019 02:51:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 340C96B0003
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 02:51:10 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id e6so10383603edi.20
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 23:51:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Z3egpdOwGBwrQgnY2sRT8PnGxYeowWb97lWA4gyDwu8=;
        b=BOXhKK93jMCnXFb6ewlbhAK1FigQfuu2XxjUTqJsEw4hdUfhRKheuur6ntx4ligWMi
         EU5FlHp50ESvfMkaQdcdi7HYnWhHxB/OaDfKlOZX/6K50/YDOfHG6mPKKCBgH5BIbeqd
         tStBl6UBOGA6REGCLt7t2LRboNgELytpoZpKvJ+7DroonX9xRZXeiBEHQxqXOhj+dhHX
         kFRtBY5TF+x/rWqHiecQP9+n0Pl4HQq49aeuvJkbR6JkOVRJMH8UO7qbBQ4KHcQZN4A6
         9qrblnQ4u94Hf4nvH2svlmva54dLOxSADXSpPqrmP+CHfV2/NgaSHC7V7C01IxG4ozCL
         izBg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUI4eljXNxO26I12xNB1DSdvklnDPhL2xbW4BjRZUValtJAcH7k
	PjSQEVamXXxXZcUXnLPXeUQMUZseMAUmxzLHohW6yN7GGZ+0JaYvqjUom1QNcuTX+sXUmwuW2Ua
	onOIy7X1ewgYoOgHuXkC44bFITgnPC0MY7hAh84GY8r7B2F7Dy4zaNffwIjXzQoU=
X-Received: by 2002:a50:9797:: with SMTP id e23mr15454308edb.265.1555397469626;
        Mon, 15 Apr 2019 23:51:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzGIeGoNAv/xmc4WtVF5NpGAA1fF4Hu+KNNav6xyCNAmnyRFIE4QaI34rU+QZUGm9xp/Dai
X-Received: by 2002:a50:9797:: with SMTP id e23mr15454254edb.265.1555397468465;
        Mon, 15 Apr 2019 23:51:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555397468; cv=none;
        d=google.com; s=arc-20160816;
        b=rctJgP8JwvHvgLef5ASnAI+IKhISpGk1sFYEFQb47ExvrpF+UU65yTdz14ck7g1nOC
         h4X3+JNbOEhBR/UqpqAIRgGMg48QdLl+tUuayQtbjWKo7Cdif/CjyilQ5gJzn4mz5l5Q
         Jqumm2ur8mFBU66NF69Y2F6NJ39YSgpVQmvESAGn2zCp6UWi7bwQEY37r/PA7NdsSN7Q
         dU0/hcD5orqRpsTFKR2BcHsWt1+D1O+3PsiJ4+VlIpWdMmEcm0QoIeLr2O6BtChl1hyJ
         fYIdd8KRgnnCL6CLf9Dkz5eixgDXSzT6xITzP1iZhZxpObekM74zsqPFBEbieVcRDYRH
         wQpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Z3egpdOwGBwrQgnY2sRT8PnGxYeowWb97lWA4gyDwu8=;
        b=HVsgVRpSf3kdX82JSkVGY+aFw1RB+JevWBJi3cZfSSq2Wj8iY6K/opi2XIPD9+dCeW
         dwXsPNpKnWnMTosFBkl9GLLgj9RlPwVn0qX8aUm6jG8kia9h5zubuAOWDjQ17AltrZHQ
         fv228XhADYgN7SgrzxmBiOBaTQ9WUO7mX9AIn1bhQComWvVxZ8YSqhykz4PLWkSllckQ
         n7tVXXlGSrGLnrtw9mwV+8vvqiIo4mh2VRZZJpKtwVZ1a+/b9JBNKVsNcCqWcUVfBkDg
         spznjeK0h1kvdVmRwQ0vKkR9GZI+lPvxaTEG3dHgnAm3dq+i5t58VUEIyktXP/4ka1Lx
         oE/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j53si3160097eda.14.2019.04.15.23.51.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 23:51:08 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C98E4ADD9;
	Tue, 16 Apr 2019 06:51:06 +0000 (UTC)
Date: Tue, 16 Apr 2019 08:50:58 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Yufen Yu <yuyufen@huawei.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH] hugetlbfs: move resv_map to hugetlbfs_inode_info
Message-ID: <20190416065058.GB11561@dhcp22.suse.cz>
References: <20190412040240.29861-1-yuyufen@huawei.com>
 <83a4e275-405f-f1d8-2245-d597bef2ec69@oracle.com>
 <20190415061618.GA16061@hori.linux.bs1.fc.nec.co.jp>
 <20190415091500.GG3366@dhcp22.suse.cz>
 <f063c3e7-1b37-7592-14c2-78b494dbd825@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f063c3e7-1b37-7592-14c2-78b494dbd825@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 15-04-19 10:11:39, Mike Kravetz wrote:
> On 4/15/19 2:15 AM, Michal Hocko wrote:
> > On Mon 15-04-19 06:16:15, Naoya Horiguchi wrote:
> >> On Fri, Apr 12, 2019 at 04:40:01PM -0700, Mike Kravetz wrote:
> >>> On 4/11/19 9:02 PM, Yufen Yu wrote:
> >>>> Commit 58b6e5e8f1ad ("hugetlbfs: fix memory leak for resv_map")
> >>> ...
> >>>> However, for inode mode that is 'S_ISBLK', hugetlbfs_evict_inode() may
> >>>> free or modify i_mapping->private_data that is owned by bdev inode,
> >>>> which is not expected!
> >>> ...
> >>>> We fix the problem by moving resv_map to hugetlbfs_inode_info. It may
> >>>> be more reasonable.
> >>>
> >>> Your patches force me to consider these potential issues.  Thank you!
> >>>
> >>> The root of all these problems (including the original leak) is that the
> >>> open of a block special inode will result in bd_acquire() overwriting the
> >>> value of inode->i_mapping.  Since hugetlbfs inodes normally contain a
> >>> resv_map at inode->i_mapping->private_data, a memory leak occurs if we do
> >>> not free the initially allocated resv_map.  In addition, when the
> >>> inode is evicted/destroyed inode->i_mapping may point to an address space
> >>> not associated with the hugetlbfs inode.  If code assumes inode->i_mapping
> >>> points to hugetlbfs inode address space at evict time, there may be bad
> >>> data references or worse.
> >>
> >> Let me ask a kind of elementary question: is there any good reason/purpose
> >> to create and use block special files on hugetlbfs?  I never heard about
> >> such usecases.
> 
> I am not aware of this as a common use case.  Yufen Yu may be able to provide
> more details about how the issue was discovered.  My guess is that it was
> discovered via code inspection.
> 
> >>                 I guess that the conflict of the usage of ->i_mapping is
> >> discovered recently and that's because block special files on hugetlbfs are
> >> just not considered until recently or well defined.  So I think that we might
> >> be better to begin with defining it first.
> 
> Unless I am mistaken, this is just like creating a device special file
> in any other filesystem.  Correct?  hugetlbfs is just some place for the
> inode/file to reside.  What happens when you open/ioctl/close/etc the file
> is really dependent on the vfs layer and underlying driver.
> 
> > A absolutely agree. Hugetlbfs is overly complicated even without that.
> > So if this is merely "we have tried it and it has blown up" kinda thing
> > then just refuse the create blockdev files or document it as undefined.
> > You need a root to do so anyway.
> 
> Can we just refuse to create device special files in hugetlbfs?  Do we need
> to worry about breaking any potential users?  I honestly do not know if anyone
> does this today.  However, if they did I believe things would "just work".

But why would anybody do something like that? Is there any actual
semantical advantage to create device files on hugetlbfs? I would be
worried that some confused application might expect e.g. hugetlb backed
pagecache for a block device or something like that. I wouldn't be too
worried to outright disallow this and only allow on an explicit and
reasonable usecase.

> The only known issue is leaking a resv_map structure when the inode is
> destroyed.  I doubt anyone would notice that leak today.
> 
> Let me do a little more research.  I think this can all be cleaned up by
> making hugetlbfs always operate on the address space embedded in the inode.
> If nothing else, a change or explanation should be added as to why most code
> operates on inode->mapping and one place operates on &inode->i_data.

Yes, that makes sense.

Thanks!
-- 
Michal Hocko
SUSE Labs

