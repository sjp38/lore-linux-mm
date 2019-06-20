Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C414C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 21:25:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F26062070B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 21:25:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F26062070B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mit.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8616D6B0005; Thu, 20 Jun 2019 17:25:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8120F8E0002; Thu, 20 Jun 2019 17:25:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 700D38E0001; Thu, 20 Jun 2019 17:25:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4BA9E6B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 17:25:22 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id o4so5337497qko.8
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 14:25:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mail-followup-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=z7yeWNDlrolP68FXZ0Ychsh0f/4mTPV1owheIRaf2MY=;
        b=igk4ivzuDA5v03DW9hODwwL/z6j0k5IH5uZmHBpDYxEbYHwKkSVgovU6QqFpsEBfV2
         jnCCTeK40gBhRzpQN8TZPBkOgKsaFIKeV/Co4dbqa9Nat//mgSLnHUTK15f/fFz8AYoo
         3NcCGIk9oE88LmV1ne7nfduiaXZ0MedY0gN+DZe5hezKxFmYMS4mxNzeOSXVFG+Y5cS6
         cFjJFyHyxifX40kvA8YINIOs+Kzbirm9MYx48hFwlAreTd7dSw248iC2crjBl33z7vgd
         eggjSCXH2eGEfY1ZD1+Kt25w9qBsH5lkWz086m0UuOVcoc/DaAeTqjWhg0c13jeO90wq
         ZmUw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
X-Gm-Message-State: APjAAAU947zvHMXvbsCSqlk1tBk293lZoAgziOrt6D88sEp2FKxhJxMB
	soljdbUz4mrNtsfVjuQVsZ/zbn/Tdde2R00lNaylzT2wd0Vxr659Ia61nayutGT/GkWmDi2JqKH
	qeeDuttFRB2oo0v9F13w47dV7WAAGhFtaZZW5mmET0TfsxmtWamU2mHv+cu8zJxefkQ==
X-Received: by 2002:aed:24d9:: with SMTP id u25mr116581526qtc.111.1561065922105;
        Thu, 20 Jun 2019 14:25:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwtFnRoLPompLdBATML3jpcj7jTBe74s3O+77oo5x//SxIBemcF63Su3LghNRUrhgi0LD/O
X-Received: by 2002:aed:24d9:: with SMTP id u25mr116581476qtc.111.1561065921481;
        Thu, 20 Jun 2019 14:25:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561065921; cv=none;
        d=google.com; s=arc-20160816;
        b=cjX4yQa4PHufaEtH2cAgsSI7S7761u5KWvAIZPxestAhnxeWJZrXhqGsmbKAk8E5rB
         Kco0DsjokUWaaL/OdC3N8uiurrLCK9IA3tszyrc4sR1GvnghyODR4H26mGwGG7wZ7jO+
         79CQtxp6vzCcgxTJmpTae346+GOprxI+gs5zUEKHXqQlDs1rCJ0H5g2HCzoRp+cpyqCE
         ZaWYGYRdIj/mOBt6737N2LvELVVAVPKHzl7keCxrELNGfyArY8jskcg8SHoLrtUhNAfM
         nGJx8V4c7Fi62+NxbJ6uVapb5QHiZr60N2qKT1SpWtwCHRVQZjkq1bLODov8HVUnneb5
         CjdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :mail-followup-to:message-id:subject:cc:to:from:date;
        bh=z7yeWNDlrolP68FXZ0Ychsh0f/4mTPV1owheIRaf2MY=;
        b=R11z4Ss1wUpHIacTNh+Djf2hzwC+eyZPPniPsRXUAPbu5Fhl+Gxx3XU5YZN2ORbPwb
         YAlMm2s2aSNIO7Wn8bbkStoIDe0xf6ZRkiLUC2Ltgw3u7l12ifiYATxvgGvVLXuq1z++
         K3nTId5A9gEtIPwRlUqFWNHWNPZgRULll4m43s453+JeFkXg0l0jW7DyKRVg8/yhh6AM
         iDNEumdvJd4JKXy3rfSSQHPJa1U05RPxUnILM12b15YKcINwscpbIuNUgzvsT87ZH4Mi
         e+fxIHzRdO4t3LJFkmmtZK7hdpJxqFz3tQVpUVtzrBm6kIwMPL7Lv6BA3dgVsAzhwGH/
         cKqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
Received: from outgoing.mit.edu (outgoing-auth-1.mit.edu. [18.9.28.11])
        by mx.google.com with ESMTPS id x22si614917qvd.87.2019.06.20.14.25.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 14:25:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) client-ip=18.9.28.11;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
Received: from callcc.thunk.org (guestnat-104-133-0-109.corp.google.com [104.133.0.109] (may be forged))
	(authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
	by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id x5KLPHSK007114
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 20 Jun 2019 17:25:18 -0400
Received: by callcc.thunk.org (Postfix, from userid 15806)
	id 86C56420484; Thu, 20 Jun 2019 17:25:17 -0400 (EDT)
Date: Thu, 20 Jun 2019 17:25:17 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
To: Ross Zwisler <zwisler@chromium.org>
Cc: linux-kernel@vger.kernel.org, Ross Zwisler <zwisler@google.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>,
        linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org, Fletcher Woodruff <fletcherw@google.com>,
        Justin TerAvest <teravest@google.com>, Jan Kara <jack@suse.cz>,
        stable@vger.kernel.org
Subject: Re: [PATCH v2 2/3] jbd2: introduce jbd2_inode dirty range scoping
Message-ID: <20190620212517.GC4650@mit.edu>
Mail-Followup-To: Theodore Ts'o <tytso@mit.edu>,
	Ross Zwisler <zwisler@chromium.org>, linux-kernel@vger.kernel.org,
	Ross Zwisler <zwisler@google.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>,
	linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org, Fletcher Woodruff <fletcherw@google.com>,
	Justin TerAvest <teravest@google.com>, Jan Kara <jack@suse.cz>,
	stable@vger.kernel.org
References: <20190620151839.195506-1-zwisler@google.com>
 <20190620151839.195506-3-zwisler@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190620151839.195506-3-zwisler@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 20, 2019 at 09:18:38AM -0600, Ross Zwisler wrote:
> diff --git a/include/linux/jbd2.h b/include/linux/jbd2.h
> index 5c04181b7c6d8..0e0393e7f41a4 100644
> --- a/include/linux/jbd2.h
> +++ b/include/linux/jbd2.h
> @@ -1397,6 +1413,12 @@ extern int	   jbd2_journal_force_commit(journal_t *);
>  extern int	   jbd2_journal_force_commit_nested(journal_t *);
>  extern int	   jbd2_journal_inode_add_write(handle_t *handle, struct jbd2_inode *inode);
>  extern int	   jbd2_journal_inode_add_wait(handle_t *handle, struct jbd2_inode *inode);
> +extern int	   jbd2_journal_inode_ranged_write(handle_t *handle,
> +			struct jbd2_inode *inode, loff_t start_byte,
> +			loff_t length);
> +extern int	   jbd2_journal_inode_ranged_wait(handle_t *handle,
> +			struct jbd2_inode *inode, loff_t start_byte,
> +			loff_t length);
>  extern int	   jbd2_journal_begin_ordered_truncate(journal_t *journal,
>  				struct jbd2_inode *inode, loff_t new_size);
>  extern void	   jbd2_journal_init_jbd_inode(struct jbd2_inode *jinode, struct inode *inode);

You're adding two new functions that are called from outside the jbd2
subsystem.  To support compiling jbd2 as a module, we also need to add
EXPORT_SYMBOL declarations for these two functions.

I'll take care of this when applying this change.

Thanks, applied.

    		     	       	       - Ted

