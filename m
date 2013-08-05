Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 0B11A6B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 11:40:21 -0400 (EDT)
Received: by mail-qc0-f179.google.com with SMTP id n10so1733871qcx.24
        for <linux-mm@kvack.org>; Mon, 05 Aug 2013 08:40:21 -0700 (PDT)
Date: Mon, 5 Aug 2013 11:40:16 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/5] cgroup: export __cgroup_from_dentry() and
 __cgroup_dput()
Message-ID: <20130805154016.GE19631@mtj.dyndns.org>
References: <1375632446-2581-1-git-send-email-tj@kernel.org>
 <1375632446-2581-3-git-send-email-tj@kernel.org>
 <51FF14C5.4040003@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51FF14C5.4040003@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 05, 2013 at 10:58:13AM +0800, Li Zefan wrote:
> > +struct cgroup *__cgroup_from_dentry(struct dentry *dentry, struct cftype **cftp)
> >  {
> > -	if (file_inode(file)->i_fop != &cgroup_file_operations)
> > -		return ERR_PTR(-EINVAL);
> > -	return __d_cft(file->f_dentry);
> > +	if (!dentry->d_inode ||
> > +	    dentry->d_inode->i_op != &cgroup_file_inode_operations)
> > +		return NULL;
> > +
> > +	if (cftp)
> > +		*cftp = __d_cft(dentry);
> > +	return __d_cgrp(dentry->d_parent);
> >  }
> > +EXPORT_SYMBOL_GPL(__cgroup_from_dentry);
> 
> As we don't expect new users, why export this symbol? memcg can't be
> built as a module.

Yeah, I for some reason was thinking memcg could be bulit as module.
Brainfart.  Dropped.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
