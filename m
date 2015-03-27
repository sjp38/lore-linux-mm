Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1315B6B0038
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 17:46:18 -0400 (EDT)
Received: by qcay5 with SMTP id y5so28304980qca.1
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 14:46:17 -0700 (PDT)
Received: from mail-qc0-x234.google.com (mail-qc0-x234.google.com. [2607:f8b0:400d:c01::234])
        by mx.google.com with ESMTPS id 65si1588838qhd.80.2015.03.27.14.46.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Mar 2015 14:46:17 -0700 (PDT)
Received: by qcto4 with SMTP id o4so28339703qct.3
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 14:46:16 -0700 (PDT)
Date: Fri, 27 Mar 2015 17:46:13 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 28/48] writeback: implement and use mapping_congested()
Message-ID: <20150327214613.GF638@htj.duckdns.org>
References: <1427086499-15657-1-git-send-email-tj@kernel.org>
 <1427086499-15657-29-git-send-email-tj@kernel.org>
 <20150327180626.GA19117@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150327180626.GA19117@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com

Hello, Vivek.

On Fri, Mar 27, 2015 at 02:06:26PM -0400, Vivek Goyal wrote:
...
> > +int mapping_congested(struct address_space *mapping,
> > +		      struct task_struct *task, int cong_bits)
> > +{
> > +	struct inode *inode = mapping->host;
> > +	struct backing_dev_info *bdi = inode_to_bdi(inode);
> > +	struct bdi_writeback *wb;
> > +	int ret = 0;
> > +
> > +	if (!inode || !inode_cgwb_enabled(inode))
> > +		return wb_congested(&bdi->wb, cong_bits);
> > +
> > +	rcu_read_lock();
> > +	wb = wb_find_current(bdi);
> 
> I am wondering that why do we lookup bdi_writeback using blkcg of
> task and why not use the bdi_writeback associated with inode?
> 
> IIUC, whole idea is to attach an inode to bdi_writeback (and
> change it later if need be) and that writeback is used for
> controlling IO to that inode. And blkcg associated with the
> writeback will be put in bio which in turn will be used
> by block layer.
> 
> IOW, blkcg of a bio gets decided by the bdi_writeback
> attached to inode and current writer does not seem to
> matter. So I am not sure why mapping_congested() should
> take task's blkcg into consideration instead of just
> taking bdi_writeback from inode and see if it is congested
> or not.

Yeap, I agree that attributing to the inode's blkcg makes more sense.
I need to think more about it but will prolly change it to use
inode->i_wb instead.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
