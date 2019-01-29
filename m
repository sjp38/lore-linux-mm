Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65BA8C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 17:04:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A9072086C
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 17:04:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="nhfcvP2T"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A9072086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B01E48E0003; Tue, 29 Jan 2019 12:04:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB0158E0002; Tue, 29 Jan 2019 12:04:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A1D38E0003; Tue, 29 Jan 2019 12:04:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 55FC68E0002
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 12:04:09 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id q64so17296530pfa.18
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 09:04:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=VV29xB00rXAvBPnOigrMJNqshqo3bC1j9EeEF+HMUno=;
        b=g79KzLXwo3AvgQPDO4HBf1llmDyGEySKEayAinv5M545q8r+AbbNiRJDE2xsYRynsD
         qKhkDXETNkH9/M8sCXkNKleB1cUMFZdxr812BchfndLrPQ3LJZ8EbbOUEN9ff0NMzjQ7
         azoDT8d1SJUfMj7cJT4pS+wkCaD7FwcJeYe1hp0LxR48XfFs7QZn5E/aciwvuzBsaz8H
         +c4IsJlnvzmFeNvhTzxGpJhZQdzhVy34a7H7AMdFira9pfhfeYx8NG13X9PQIUNXjDI1
         etJtj4E0PqJ4gjhpPaZ2EjayptSpqPEXXhJCYPnp9Gs+/Baz9FswyXHRP0W5GymuNMq9
         tMig==
X-Gm-Message-State: AJcUukfdI/0bJX+Ceavb5jQ46luKvPg6hBE9qyasZ51pce0E7ei8uzHK
	qM43nf55EIWQOO+z4kDq+RVw1w0omz5AAp4ZWiDbXeQVc0eSb7lx9QehDnh4g+ww0b/WU8/vThG
	nP78G0zcnBGpTpXBjKIKLrDMrZmCyTPPVpxMWGgZS22Ikp8fBZ4rggWQYpXgBZUhllWuvkqSd/N
	uBNNThYm6cqNQIDYZXWXs87GbbupfZt2X1T2/EjzMeXUxA/AUTMY/Pdi15PbewCNCeys3g6XOT1
	516Z/aztrPfkWtAgKWz114JDqLKhCM0cTx/mONmYCYShQTJBafMYlQ1d3KYHgSnwykZtYy7rAVT
	690MoWF0Pyktm/djYris65O9z9KUSLUytokiLKz8RE0EDeaQYAOtdgBNAYF1nJQ0n7ggfbEJ1CY
	L
X-Received: by 2002:a17:902:29ab:: with SMTP id h40mr26610669plb.238.1548781449016;
        Tue, 29 Jan 2019 09:04:09 -0800 (PST)
X-Received: by 2002:a17:902:29ab:: with SMTP id h40mr26610623plb.238.1548781448276;
        Tue, 29 Jan 2019 09:04:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548781448; cv=none;
        d=google.com; s=arc-20160816;
        b=t2HcT047S4ijE9sW1zXOaeu94mGUpF+fjGxxvh2SOGc4e2PuCZ8dm9oNgLleGzQSdu
         4oGENobq+Faq5tn6icZa4M5Pc4xhxNWTVFO+NN0A560izogNjKt85c9bRkaDnE4MhHyW
         yqfZ89/G9NlnhW29chL7fOc3xe8CYcNwAk7BKOgfqyb4etKpBaWBowDG0uqo2x9ZDYvi
         A2hyZNzwZq96iWSVO27LjUiQnFfhZCCzysIfDZZg3goeyV40T0QthCX338ov0/290Kff
         wMmWqc5C7RqTrnmHobFqQZpgxAOTtCix7k1+SiPiaL7EEQLkUiJ4vephUFxLF/KQChvC
         OEWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=VV29xB00rXAvBPnOigrMJNqshqo3bC1j9EeEF+HMUno=;
        b=GqHOlVRVjXJFXtFDbs6KV7ZdSLjfwe8fPH+BguNQwJPEpkak/zb7Gy/SeA3qnU3Xlq
         gSiqch6B3fwcGWIWgg7gX7RiHQebxNUMVLpcIrUlID2svmULPzZAPt19vAzAmh7ohMTj
         XT3uoOX7pQfNvckNSD6HOPdQOFzEms27K2BpVj/muXHKINiBBiuxfX9TYppFi0h7XjWV
         N696CeJycTql0qMAxmBONb1k1ccTmcadizcvMMsKVWTRk/oaDgBuYewdvl2P2zP1XjXf
         l2vZB5xavWPSYfKqqK1y5G2KyAjmr3LZkEFHWsN2xiOBbXMDDefEPIwwpBj1W1V3NLCH
         f8Ag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=nhfcvP2T;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b5sor55204353pgq.18.2019.01.29.09.04.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 09:04:08 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=nhfcvP2T;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=VV29xB00rXAvBPnOigrMJNqshqo3bC1j9EeEF+HMUno=;
        b=nhfcvP2TxdnZN9xbwSrI15JOAP/kbT54fpb0kysxy1Ck6JcaCOMnXa3XG15L8LW4Yt
         rg+A9YZLOttrpv6lotsweo7NS7Mpg0XA8UAPg1BvZFCJpmMZf8tyntT9yE2z8ijvKmOD
         YjD9/NvOmJzAQiEorJ115Nq29NtG0hpSa3ZKDqwahfC/BNHes9xmIX+1v28uM4eg1Fyo
         pz5++Lf/EyXLG9VzoDQkvpiQZiCWScHse7aQmivAwAp+rs0RcvwnXFUVIMIScN3aLhTn
         PvM5gibVPP5/5p8miAiCyjG77abUcfqTwd5qHOgxfH/Z25eqZEvWJs6H9fOmGfZ0lI/i
         ZISg==
X-Google-Smtp-Source: ALg8bN7AxF3xoqsuG/93xSoZ+cRG7a8tyhRZlL24OqrBTYhU6jme9FBFjiBzWS6Haq2KiW/HN/k8Rw==
X-Received: by 2002:a63:34c3:: with SMTP id b186mr23539295pga.184.1548781447762;
        Tue, 29 Jan 2019 09:04:07 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id c67sm67656941pfg.170.2019.01.29.09.04.06
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 09:04:06 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1goWnu-0003HW-72; Tue, 29 Jan 2019 10:04:06 -0700
Date: Tue, 29 Jan 2019 10:04:06 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Joel Nider <joeln@il.ibm.com>
Cc: Leon Romanovsky <leon@kernel.org>, Doug Ledford <dledford@redhat.com>,
	Mike Rapoport <rppt@linux.ibm.com>, linux-mm@kvack.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 5/5] RDMA/uverbs: add UVERBS_METHOD_REG_REMOTE_MR
Message-ID: <20190129170406.GD10094@ziepe.ca>
References: <1548768386-28289-1-git-send-email-joeln@il.ibm.com>
 <1548768386-28289-6-git-send-email-joeln@il.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1548768386-28289-6-git-send-email-joeln@il.ibm.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 03:26:26PM +0200, Joel Nider wrote:
> Add a new handler for new uverb reg_remote_mr. The purpose is to register
> a memory region in a different address space (i.e. process) than the
> caller.
> 
> The main use case which motivated this change is post-copy container
> migration. When a migration manager (i.e. CRIU) starts a migration, it
> must have an open connection for handling any page faults that occur
> in the container after restoration on the target machine. Even though
> CRIU establishes and maintains the connection, ultimately the memory
> is copied from the container being migrated (i.e. a remote address
> space). This container must remain passive -- meaning it cannot have
> any knowledge of the RDMA connection; therefore the migration manager
> must have the ability to register a remote memory region. This remote
> memory region will serve as the source for any memory pages that must
> be copied (on-demand or otherwise) during the migration.
> 
> Signed-off-by: Joel Nider <joeln@il.ibm.com>
>  drivers/infiniband/core/uverbs_std_types_mr.c | 129 +++++++++++++++++++++++++-
>  include/rdma/ib_verbs.h                       |   8 ++
>  include/uapi/rdma/ib_user_ioctl_cmds.h        |  13 +++
>  3 files changed, 149 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/infiniband/core/uverbs_std_types_mr.c b/drivers/infiniband/core/uverbs_std_types_mr.c
> index 4d4be0c..bf7b4b2 100644
> +++ b/drivers/infiniband/core/uverbs_std_types_mr.c
> @@ -150,6 +150,99 @@ static int UVERBS_HANDLER(UVERBS_METHOD_DM_MR_REG)(
>  	return ret;
>  }
>  
> +static int UVERBS_HANDLER(UVERBS_METHOD_REG_REMOTE_MR)(
> +	struct uverbs_attr_bundle *attrs)
> +{

I think this should just be REG_MR with an optional remote PID
argument

> +	struct pid *owner_pid;
> +	struct ib_reg_remote_mr_attr attr = {};
> +	struct ib_uobject *uobj =
> +		uverbs_attr_get_uobject(attrs,
> +					UVERBS_ATTR_REG_REMOTE_MR_HANDLE);
> +	struct ib_pd *pd =
> +		uverbs_attr_get_obj(attrs, UVERBS_ATTR_REG_REMOTE_MR_PD_HANDLE);
> +
> +	struct ib_mr *mr;
> +	int ret;
> +
> +	ret = uverbs_copy_from(&attr.start, attrs,
> +				UVERBS_ATTR_REG_REMOTE_MR_START);
> +	if (ret)
> +		return ret;
> +
> +	ret = uverbs_copy_from(&attr.length, attrs,
> +				UVERBS_ATTR_REG_REMOTE_MR_LENGTH);
> +	if (ret)
> +		return ret;
> +
> +	ret = uverbs_copy_from(&attr.hca_va, attrs,
> +				UVERBS_ATTR_REG_REMOTE_MR_HCA_VA);
> +	if (ret)
> +		return ret;
> +
> +	ret = uverbs_copy_from(&attr.owner, attrs,
> +				UVERBS_ATTR_REG_REMOTE_MR_OWNER);
> +	if (ret)
> +		return ret;

Maybe these should use the const version, it is becoming intended for
small integers, then we can do sensible things like use uintptr_t to
store pointer values, and size_t to store sizes - the code will
automatically bounds check the user input if it is done like this.

> +	ret = uverbs_get_flags32(&attr.access_flags, attrs,
> +				 UVERBS_ATTR_REG_REMOTE_MR_ACCESS_FLAGS,
> +				 IB_ACCESS_SUPPORTED);
> +	if (ret)
> +		return ret;
> +
> +	/* ensure the offsets are identical */
> +	if ((attr.start & ~PAGE_MASK) != (attr.hca_va & ~PAGE_MASK))
> +		return -EINVAL;
> +
> +	ret = ib_check_mr_access(attr.access_flags);
> +	if (ret)
> +		return ret;
> +
> +	if (attr.access_flags & IB_ACCESS_ON_DEMAND) {
> +		if (!(pd->device->attrs.device_cap_flags &
> +		      IB_DEVICE_ON_DEMAND_PAGING)) {
> +			pr_debug("ODP support not available\n");
> +			ret = -EINVAL;
> +			return ret;
> +		}
> +	}
> +
> +	/* get the owner's pid struct before something happens to it */
> +	owner_pid = find_get_pid(attr.owner);

security? Match what ptrace does?

> +	mr = pd->device->ops.reg_user_mr(pd, attr.start, attr.length,
> +		attr.hca_va, attr.access_flags, owner_pid, NULL);
> +	if (IS_ERR(mr))
> +		return PTR_ERR(mr);
> +
> +	mr->device  = pd->device;
> +	mr->pd      = pd;
> +	mr->dm	    = NULL;
> +	mr->uobject = uobj;
> +	atomic_inc(&pd->usecnt);
> +	mr->res.type = RDMA_RESTRACK_MR;
> +	mr->res.task = get_pid_task(owner_pid, PIDTYPE_PID);
> +	rdma_restrack_kadd(&mr->res);
> +
> +	uobj->object = mr;
> +
> +	ret = uverbs_copy_to(attrs, UVERBS_ATTR_REG_REMOTE_MR_RESP_LKEY,
> +		   &mr->lkey, sizeof(mr->lkey));
> +	if (ret)
> +		goto err_dereg;
> +
> +	ret = uverbs_copy_to(attrs, UVERBS_ATTR_REG_REMOTE_MR_RESP_RKEY,
> +			&mr->rkey, sizeof(mr->rkey));
> +	if (ret)
> +		goto err_dereg;
> +
> +	return 0;
> +
> +err_dereg:
> +	ib_dereg_mr(mr);
> +
> +	return ret;
> +}
> +
>  DECLARE_UVERBS_NAMED_METHOD(
>  	UVERBS_METHOD_ADVISE_MR,
>  	UVERBS_ATTR_IDR(UVERBS_ATTR_ADVISE_MR_PD_HANDLE,
> @@ -203,12 +296,46 @@ DECLARE_UVERBS_NAMED_METHOD_DESTROY(
>  			UVERBS_ACCESS_DESTROY,
>  			UA_MANDATORY));
>  
> +DECLARE_UVERBS_NAMED_METHOD(
> +	UVERBS_METHOD_REG_REMOTE_MR,
> +	UVERBS_ATTR_IDR(UVERBS_ATTR_REG_REMOTE_MR_HANDLE,
> +			UVERBS_OBJECT_MR,
> +			UVERBS_ACCESS_NEW,
> +			UA_MANDATORY),
> +	UVERBS_ATTR_IDR(UVERBS_ATTR_REG_REMOTE_MR_PD_HANDLE,
> +			UVERBS_OBJECT_PD,
> +			UVERBS_ACCESS_READ,
> +			UA_MANDATORY),
> +	UVERBS_ATTR_PTR_IN(UVERBS_ATTR_REG_REMOTE_MR_START,
> +			   UVERBS_ATTR_TYPE(u64),
> +			   UA_MANDATORY),
> +	UVERBS_ATTR_PTR_IN(UVERBS_ATTR_REG_REMOTE_MR_LENGTH,
> +			   UVERBS_ATTR_TYPE(u64),
> +			   UA_MANDATORY),
> +	UVERBS_ATTR_PTR_IN(UVERBS_ATTR_REG_REMOTE_MR_HCA_VA,
> +			   UVERBS_ATTR_TYPE(u64),
> +			   UA_MANDATORY),
> +	UVERBS_ATTR_FLAGS_IN(UVERBS_ATTR_REG_REMOTE_MR_ACCESS_FLAGS,
> +			     enum ib_access_flags),
> +	UVERBS_ATTR_PTR_IN(UVERBS_ATTR_REG_REMOTE_MR_OWNER,
> +			   UVERBS_ATTR_TYPE(u32),
> +			   UA_MANDATORY),
> +	UVERBS_ATTR_PTR_OUT(UVERBS_ATTR_REG_REMOTE_MR_RESP_LKEY,
> +			    UVERBS_ATTR_TYPE(u32),
> +			    UA_MANDATORY),
> +	UVERBS_ATTR_PTR_OUT(UVERBS_ATTR_REG_REMOTE_MR_RESP_RKEY,
> +			    UVERBS_ATTR_TYPE(u32),
> +			    UA_MANDATORY),
> +);
> +
>  DECLARE_UVERBS_NAMED_OBJECT(
>  	UVERBS_OBJECT_MR,
>  	UVERBS_TYPE_ALLOC_IDR(uverbs_free_mr),
>  	&UVERBS_METHOD(UVERBS_METHOD_DM_MR_REG),
>  	&UVERBS_METHOD(UVERBS_METHOD_MR_DESTROY),
> -	&UVERBS_METHOD(UVERBS_METHOD_ADVISE_MR));
> +	&UVERBS_METHOD(UVERBS_METHOD_ADVISE_MR),
> +	&UVERBS_METHOD(UVERBS_METHOD_REG_REMOTE_MR),
> +);

I'm kind of surprised this compiles with the trailing comma?

>  const struct uapi_definition uverbs_def_obj_mr[] = {
>  	UAPI_DEF_CHAIN_OBJ_TREE_NAMED(UVERBS_OBJECT_MR,
> diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
> index 3432404..dcf5edc 100644
> +++ b/include/rdma/ib_verbs.h
> @@ -334,6 +334,14 @@ struct ib_dm_alloc_attr {
>  	u32	flags;
>  };
>  
> +struct ib_reg_remote_mr_attr {
> +	u64      start;
> +	u64      length;
> +	u64      hca_va;
> +	u32      access_flags;
> +	u32      owner;
> +};

Why? Why here?

Jason

