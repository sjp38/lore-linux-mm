Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61891C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 09:58:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B5D5206BA
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 09:58:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B5D5206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9DB98E0012; Mon, 11 Mar 2019 05:58:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4F1A8E0002; Mon, 11 Mar 2019 05:58:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 93BCE8E0012; Mon, 11 Mar 2019 05:58:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6D8158E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 05:58:54 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id 43so4716811qtz.8
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 02:58:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=PGlZNpLPnrRz03ht6RYxyNkJoNZ/4fN59S595sf35EM=;
        b=HBc3DSZrHzjK5fS2vIjKA/9NqXMnEAzbloPmrvNwjXAHiFDrJjuSfBW780STSe1qTG
         5T5paDShzgX3+booQkPR/Chx8ELgJrKZIgATw0ebo4WnMElXduwWKaxz9voJ4sBL0qiA
         GE/sd+wvQ4uXfI78waWCvuLNO4lBHaNwJ2JyxEr101cRcArlUUJhRNfGdguaX8yyT9wh
         vtUj9sILKK+XtunHHKUrBOEFVAvh9h0lgCACxDv5+PfGY2RMH3Ebjk173W+J9Vi7jVSv
         N3eR/fz1tlniUKjDZmZZ0d6kuYToJda3D7hYmRyQe144EaAfxSUvt+UC2p6pHgHlWaSG
         GfeQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXm7IQAsFc6Moe7ezPnrMKL8QiqfiKF2o1bwwXKXfvb+jb2RiDy
	vz6f2BbNWzZ484EW/qaXY6QDnBP/HeEPl/zhtIr10zCOZBQUpgNeADg4cxSq70jh3ZQtaiKpAJ/
	X2eiwgySDht+iOwBp9q+hw6S4LT4c4MbDyPQCJYrmQBDPZCvnbQDJFDoOfjJO73ZaiA==
X-Received: by 2002:a0c:fa92:: with SMTP id o18mr5953290qvn.81.1552298334229;
        Mon, 11 Mar 2019 02:58:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxukSI1KopqEwQ9LcMwaxyN45h5aq083kaOxDuvUCXkHAda0MhSsk4IxHwaIQSsZM2OXK2P
X-Received: by 2002:a0c:fa92:: with SMTP id o18mr5953266qvn.81.1552298333538;
        Mon, 11 Mar 2019 02:58:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552298333; cv=none;
        d=google.com; s=arc-20160816;
        b=PoJqL5zqgrMBQq1xkdaeWpxNbFtK//lKHXs3JoNY9wibdbbRK4Mxqy4aDH9QteeTgt
         sR0AEV5j9TsrzUS1k0d/8Wi+2fgXsVe9R+at0QcR1EWFp9IBHp7I7R1DhVZuPjaEuNWS
         z7DzbhVtA0aceiiV5g7BCW9nhEFmZ0rXDLQ5UKSkgq0mCDVQ63Vf8AddFAw8mobvwLuv
         YamRpqCf6MJ/bojryv1t8pnTG++rCDnmO0PlIHQFSvekPOvIopaAzvr65zXEjyG3ePpt
         Q7RzMwRhV9++QHXFL81jBqM+8+ZIli5nZvswuv20kt6spWT+vhDW5k8Km0HH+nmd2JLW
         H1+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=PGlZNpLPnrRz03ht6RYxyNkJoNZ/4fN59S595sf35EM=;
        b=GXHQ3OkJHhYibBqmSutQYfBzCmbOHypUbCCjZjvkNzsKUbJSIrDnnC1p2qpzF48Ygi
         KTHJefcDKrfOCipJF8Crg2ILcE3dkG/ICF+28+52B6DwmoVE4du6uuuCzHFaeCBcLBCN
         1kw6KoQoDmqVVZhnLFmVQo4ydXjnN7N9sVB+ZsAw/9Rg9JDN9mIGg5tRArMAY73qyeZA
         hReJaUN+yn1vnbcPeguUwvyhc4n4LTk+1TmkrikMQKHJ2cgV6guu2YVTBvhKYiIsUa8R
         BAFdBCjXbYnG6qPp2vtbxr3otl+5ZVp0/dtN58SxMav2qKDvbc9gPuzZ7BA+JFCF9xhO
         Ecsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 24si3068796qtm.284.2019.03.11.02.58.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 02:58:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D87BA3086265;
	Mon, 11 Mar 2019 09:58:51 +0000 (UTC)
Received: from xz-x1 (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 8C4DB5DA38;
	Mon, 11 Mar 2019 09:58:42 +0000 (UTC)
Date: Mon, 11 Mar 2019 17:58:40 +0800
From: Peter Xu <peterx@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Paolo Bonzini <pbonzini@redhat.com>, Hugh Dickins <hughd@google.com>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Maxime Coquelin <maxime.coquelin@redhat.com>, kvm@vger.kernel.org,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>, linux-mm@kvack.org,
	Marty McFadden <mcfadden8@llnl.gov>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	linux-fsdevel@vger.kernel.org,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] userfaultfd: apply unprivileged_userfaultfd check
Message-ID: <20190311095840.GA14108@xz-x1>
References: <20190311093701.15734-1-peterx@redhat.com>
 <20190311093701.15734-4-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190311093701.15734-4-peterx@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Mon, 11 Mar 2019 09:58:52 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 05:37:01PM +0800, Peter Xu wrote:
> Apply the unprivileged_userfaultfd check when doing userfaultfd
> syscall.  We didn't check it in other paths of userfaultfd (e.g., the
> ioctl() path) because we don't want to drag down the fast path of
> userfaultfd, as suggested by Andrea.
> 
> Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
> Suggested-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Signed-off-by: Peter Xu <peterx@redhat.com>
> ---
>  fs/userfaultfd.c | 25 +++++++++++++++++++++++++
>  1 file changed, 25 insertions(+)
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index c2188464555a..effdcfc88629 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -951,6 +951,28 @@ void userfaultfd_unmap_complete(struct mm_struct *mm, struct list_head *uf)
>  	}
>  }
>  
> +/* Whether current process allows to use userfaultfd syscalls */
> +static bool userfaultfd_allowed(void)
> +{
> +	bool allowed = false;
> +
> +	switch (unprivileged_userfaultfd) {
> +	case UFFD_UNPRIV_ENABLED:
> +		allowed = true;
> +		break;
> +	case UFFD_UNPRIV_KVM:
> +		allowed = !!test_bit(MMF_USERFAULTFD_ALLOW,
> +				     &current->mm->flags);
> +		/* Fall through */

Sorry I should squash this in otherwise compilation of !CONFIG_KVM
will break:

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index effdcfc88629..1b3fa5935643 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -960,10 +960,12 @@ static bool userfaultfd_allowed(void)
        case UFFD_UNPRIV_ENABLED:
                allowed = true;
                break;
+#if IS_ENABLED(CONFIG_KVM)
        case UFFD_UNPRIV_KVM:
                allowed = !!test_bit(MMF_USERFAULTFD_ALLOW,
                                     &current->mm->flags);
                /* Fall through */
+#endif
        case UFFD_UNPRIV_DISABLED:
                allowed = allowed || ns_capable(current_user_ns(),
                                                CAP_SYS_PTRACE);

Will wait for more comments before I repost.  Sorry for the noise.

Regards,

-- 
Peter Xu

