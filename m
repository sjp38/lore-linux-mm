Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DEA7C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 14:37:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B430E20665
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 14:37:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=android.com header.i=@android.com header.b="MFtq1gVo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B430E20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=android.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6107F6B0007; Tue, 13 Aug 2019 10:37:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C0EB6B0008; Tue, 13 Aug 2019 10:37:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4601A6B000A; Tue, 13 Aug 2019 10:37:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0234.hostedemail.com [216.40.44.234])
	by kanga.kvack.org (Postfix) with ESMTP id 199876B0007
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 10:37:36 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id C7A05180AD7C3
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 14:37:35 +0000 (UTC)
X-FDA: 75817658070.24.farm89_802bf0e3531d
X-HE-Tag: farm89_802bf0e3531d
X-Filterd-Recvd-Size: 8237
Received: from mail-pl1-f195.google.com (mail-pl1-f195.google.com [209.85.214.195])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 14:37:34 +0000 (UTC)
Received: by mail-pl1-f195.google.com with SMTP id m9so49195746pls.8
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 07:37:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=android.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=bw4HKPsz5KHcjk6HSfejuCsIw3GJFzkr29hAUy0bps0=;
        b=MFtq1gVoaeUSMonwadLhXhTtdodprj0ov0yRnwcJzaEizH9iXc2AyEe2YsLLjL9Em/
         DnRWUrLHNQkMs6a4pyzNtrfV9fh+f0WakaT7EGR/SddCESx4gNUJvdWbI0AnPn8pRpA3
         wgmNSZiOuSrw44CJp44y0pGPN0U6VzVYkB7JCci+tCmHHs3IKTEqfV+veY5UEDP6fcp7
         FcnOe1UR/JGhNA1vKqUgRY0O8lDkppt5VkhCp5z7ne3Sr1+pfITYHkHNFOIDKkVzXAz3
         95wisabfmhqSW6q/xPUyroW+UZ9ddmhvgoPCBG7x434/HPUw3rZO1bStEKXJRGENRSDr
         pjCg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=bw4HKPsz5KHcjk6HSfejuCsIw3GJFzkr29hAUy0bps0=;
        b=TqgP+D+jRnZuBZ2fAn5ZSnIejO+Kd/kz1kUCAf8/37vEyk64kG8M39QWBzIJQhBZ+f
         2MTmTgbEfBT2Xs/rOvUyQiGvUMgdPp+JA1nP3TB7gOLzPhjjONosmI2FWa2L3uXyAH42
         CgU/EfUWYVRhduTyPyqircDWH43Cc46DIm5MpkBZNb+UPx1/Iq1ABW++REP1QNo+xZj8
         WGUUKxLpQUdHAW2eDTSh/NqI5Jx+ZGE5yX7mGJ03zUUFkV730PZG8chILoxuRZzNCLAv
         EpqEBcPxWqbEiMxYPlBYWE8NdK/Ogx5rdhx33rrSqvzHiB3mEad5+K5DCnhX5dePKeQ0
         CVSw==
X-Gm-Message-State: APjAAAV7jfNF7Xi7zkCfR5sso+OtKpEZ9/hQpZxGbm3JwNcsjbahRFCF
	ph7tbeFq0ZQE/icE6NUQoGZGFg==
X-Google-Smtp-Source: APXvYqyXJXgYI0HIs6xWxNQDIPLGgCxznsuGq+ryK3xceeQe7Za7UsLXSNSEqPCOTlNm5RgIykOuPA==
X-Received: by 2002:a17:902:aa03:: with SMTP id be3mr38125628plb.240.1565707053626;
        Tue, 13 Aug 2019 07:37:33 -0700 (PDT)
Received: from nebulus.mtv.corp.google.com ([2620:15c:211:200:5404:91ba:59dc:9400])
        by smtp.googlemail.com with ESMTPSA id v63sm114972475pfv.174.2019.08.13.07.37.30
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Aug 2019 07:37:32 -0700 (PDT)
Subject: Re: [PATCH] Add flags option to get xattr method paired to
 __vfs_getxattr
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, kernel-team@android.com,
 Stephen Smalley <sds@tycho.nsa.gov>, linux-security-module@vger.kernel.org,
 stable@vger.kernel.org, Eric Van Hensbergen <ericvh@gmail.com>,
 Latchesar Ionkov <lucho@ionkov.net>,
 Dominique Martinet <asmadeus@codewreck.org>,
 David Howells <dhowells@redhat.com>, Chris Mason <clm@fb.com>,
 Josef Bacik <josef@toxicpanda.com>, David Sterba <dsterba@suse.com>,
 Jeff Layton <jlayton@kernel.org>, Sage Weil <sage@redhat.com>,
 Ilya Dryomov <idryomov@gmail.com>, Steve French <sfrench@samba.org>,
 Tyler Hicks <tyhicks@canonical.com>, Jan Kara <jack@suse.com>,
 Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>,
 Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>,
 Miklos Szeredi <miklos@szeredi.hu>, Bob Peterson <rpeterso@redhat.com>,
 Andreas Gruenbacher <agruenba@redhat.com>,
 David Woodhouse <dwmw2@infradead.org>, Richard Weinberger <richard@nod.at>,
 Dave Kleikamp <shaggy@kernel.org>, Tejun Heo <tj@kernel.org>,
 Trond Myklebust <trond.myklebust@hammerspace.com>,
 Anna Schumaker <anna.schumaker@netapp.com>, Mark Fasheh <mark@fasheh.com>,
 Joel Becker <jlbec@evilplan.org>, Joseph Qi <joseph.qi@linux.alibaba.com>,
 Mike Marshall <hubcap@omnibond.com>, Martin Brandenburg
 <martin@omnibond.com>, Alexander Viro <viro@zeniv.linux.org.uk>,
 Phillip Lougher <phillip@squashfs.org.uk>,
 "Darrick J. Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org,
 Hugh Dickins <hughd@google.com>, "David S. Miller" <davem@davemloft.net>,
 Serge Hallyn <serge@hallyn.com>, James Morris <jmorris@namei.org>,
 Mimi Zohar <zohar@linux.ibm.com>, Paul Moore <paul@paul-moore.com>,
 Eric Paris <eparis@parisplace.org>, Casey Schaufler
 <casey@schaufler-ca.com>, Andrew Morton <akpm@linux-foundation.org>,
 Vyacheslav Dubeyko <slava@dubeyko.com>,
 =?UTF-8?Q?Ernesto_A=2e_Fern=c3=a1ndez?= <ernesto.mnd.fernandez@gmail.com>,
 Mathieu Malaterre <malat@debian.org>, v9fs-developer@lists.sourceforge.net,
 linux-afs@lists.infradead.org, linux-btrfs@vger.kernel.org,
 ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
 samba-technical@lists.samba.org, ecryptfs@vger.kernel.org,
 linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
 linux-fsdevel@vger.kernel.org, cluster-devel@redhat.com,
 linux-mtd@lists.infradead.org, jfs-discussion@lists.sourceforge.net,
 linux-nfs@vger.kernel.org, ocfs2-devel@oss.oracle.com,
 devel@lists.orangefs.org, linux-unionfs@vger.kernel.org,
 reiserfs-devel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org,
 linux-integrity@vger.kernel.org, selinux@vger.kernel.org
References: <20190812193320.200472-1-salyzyn@android.com>
 <20190813084801.GA972@kroah.com>
From: Mark Salyzyn <salyzyn@android.com>
Message-ID: <e211bef2-f346-c9c7-f4b8-c774159b14e1@android.com>
Date: Tue, 13 Aug 2019 07:37:29 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190813084801.GA972@kroah.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/13/19 1:48 AM, Greg Kroah-Hartman wrote:
> On Mon, Aug 12, 2019 at 12:32:49PM -0700, Mark Salyzyn wrote:
>> --- a/include/linux/xattr.h
>> +++ b/include/linux/xattr.h
>> @@ -30,10 +30,10 @@ struct xattr_handler {
>>   	const char *prefix;
>>   	int flags;      /* fs private flags */
>>   	bool (*list)(struct dentry *dentry);
>> -	int (*get)(const struct xattr_handler *, struct dentry *dentry,
>> +	int (*get)(const struct xattr_handler *handler, struct dentry *dentry,
>>   		   struct inode *inode, const char *name, void *buffer,
>> -		   size_t size);
>> -	int (*set)(const struct xattr_handler *, struct dentry *dentry,
>> +		   size_t size, int flags);
>> +	int (*set)(const struct xattr_handler *handler, struct dentry *dentry,
>>   		   struct inode *inode, const char *name, const void *buffer,
>>   		   size_t size, int flags);
> Wow, 7 arguments.  Isn't there some nice rule of thumb that says once
> you get more then 5, a function becomes impossible to understand?

This is a method with a pot-pourri of somewhat intuitive useful, but not 
always necessary, arguments, the additional argument does not complicate 
the function(s) AFAIK, but maybe its usage. Most functions do not even 
reference handler, the inode is typically a derivative of dentry, The 
arguments most used are the name of the attribute and the buffer/size 
the results are to be placed into.

The addition of flags is actually a pattern borrowed from the [.]set 
method, which provides at least 32 bits of 'control' (of which we added 
only one). Before, it was an anti-pattern.

> Surely this could be a structure passed in here somehow, that way when
> you add the 8th argument in the future, you don't have to change
> everything yet again?  :)
Just be happy I provided int flags, instead of bool no_security ;-> 
there are a few bits there that can be used in the future.
> I don't have anything concrete to offer as a replacement fix for this,
> but to me this just feels really wrong...

I went through 6 different alternatives (in the overlayfs security fix 
patch set) until I found this one that resonated with the security and 
filesystem stakeholders. The one was a direct result of trying to reduce 
the security attack surface. This code was created by threading a 
needle, and evolution. I am game for a 7th alternative to solve the 
unionfs set of recursive calls into acquiring the extended attributes.

-- Mark

