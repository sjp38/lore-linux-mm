Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5511C76194
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 13:37:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8ED9D227BE
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 13:37:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8ED9D227BE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F9AA6B0010; Tue, 23 Jul 2019 09:37:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A9F98E0003; Tue, 23 Jul 2019 09:37:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19A3B8E0002; Tue, 23 Jul 2019 09:37:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id EFA036B0010
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 09:37:49 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id n190so36487139qkd.5
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 06:37:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=mqC+xX/Fq5iqSc3/JQ70s2bV87ucUOEds/fa0kGVLxg=;
        b=pep8sLYBdnljlUk+Lxf1LV5diOgU2NhryGVVsCWyPVTskyX7iVRPjC//8qNm/WYh+n
         uYz8Li8lky4jCEc3wP9O+2wu7fNWKQS8homfaoW333aQhkaYCJQ3h23M82naCzFA0gRG
         6eLnpExy1jTPv9VW8x+GN51NsonayuvVrx1QZ3k4IMdkzR+0fFF+4qAtRM8jnO6KqiIp
         hfUU+BB21LGNcJk02pxtXOJyq+aAqPzYzPKBmctvHOfYpZV1L409rNynU7NrFe0geyUT
         72fA7GFUPOXV1wQvnW17tGfxWl6q1Xx27mKeny7LaLY7i+rA+UAkIMesOHEgLF5QJwNC
         gGzg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVFjJC9R6HiyMx5tlP66lDnLPfB4kOj5VpSoi7UPK7a16cvH+4W
	cmvDsX9JUBjqRDYgefzEQD3e7i5rZ9WE+fh0HWTJ11GWla1FZ0Ne1aM17BHjhYDRWVSz+hMF5VW
	unAmEGT7EcHXEz9dAud19FfqvB8++tVoQhcAWEcLA6HjevnVWyMP/jzYbOSmYNeyMBg==
X-Received: by 2002:ae9:e707:: with SMTP id m7mr51431026qka.50.1563889069760;
        Tue, 23 Jul 2019 06:37:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyC4SoOdg+TAkxLwE4Wr3nPeeZa2PIxLfUUnlJqhUmcFmLKIPb4SGe3vJdnP2qXUzbkU+pB
X-Received: by 2002:ae9:e707:: with SMTP id m7mr51431000qka.50.1563889069310;
        Tue, 23 Jul 2019 06:37:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563889069; cv=none;
        d=google.com; s=arc-20160816;
        b=V14YIeKbFJ9EbbN740SqhjpnlrXKlZTmrkilbRui11qFd4CrpnbDzpZla55LkbWYah
         dL+wonOQsHp/0RtTxe3w+4/cr/4B85kHOFLMmdOZj2saBTozHC8wpc6N8M2f4plDQrKh
         hA1LQ2bJ0ZkZ1g+haa8zhj0lEXIALsMMiq4UYhnvOvx7zHSV8I/2S037EcC1l1SrUW0R
         6rCJli9eXE69pF9KIbkrJZf4MOWHNbeOumQZYjc61/nDWjVS8gOgA3++Pr+AtLlGVpwb
         iu8cx5EWHB3azatN2CThfDh3ITxYcqQOqsZbR9AoatC3+dm4HGctbiJRssXn2OVKLdWQ
         hh5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=mqC+xX/Fq5iqSc3/JQ70s2bV87ucUOEds/fa0kGVLxg=;
        b=PwLPkguWfQdAilzt7ZDeS5D/tXoj4PGa2l0koqYxvNLog25bZxsIYMVg00N0bSOQLX
         mlfxrVJxkbhhSQ+BsiOdKkiHCHnlkSrSC0B0NEHMkOqVuoKa/C2Yu+jrKFSqZt4UZlAg
         8AJiaN2FsQL5zIINhihYSjEMV+88LLKFWw6b9DSI/G03JL0vRDluQv/o+5ii6q6kXvvj
         QxWj7uICVTUwXnxXI5W8F4V+Phxo4HT84bPUkXUSQcylyfKPeSydWzeubd3ZCx5++Qtn
         v/odXnEXfKYUMUtBdf2HY3az8gKhcQ2gIGgwiBkhTvpIwMYqA1bewyN+ROnS07awpnYz
         +FNw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z57si24698218qta.330.2019.07.23.06.37.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 06:37:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4B9B230C34D1;
	Tue, 23 Jul 2019 13:37:48 +0000 (UTC)
Received: from [10.72.12.26] (ovpn-12-26.pek2.redhat.com [10.72.12.26])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D55375D9C5;
	Tue, 23 Jul 2019 13:37:18 +0000 (UTC)
Subject: Re: WARNING in __mmdrop
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: syzbot <syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com>,
 aarcange@redhat.com, akpm@linux-foundation.org, christian@brauner.io,
 davem@davemloft.net, ebiederm@xmission.com, elena.reshetova@intel.com,
 guro@fb.com, hch@infradead.org, james.bottomley@hansenpartnership.com,
 jglisse@redhat.com, keescook@chromium.org, ldv@altlinux.org,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux-parisc@vger.kernel.org, luto@amacapital.net,
 mhocko@suse.com, mingo@kernel.org, namit@vmware.com, peterz@infradead.org,
 syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk, wad@chromium.org
References: <0000000000008dd6bb058e006938@google.com>
 <000000000000964b0d058e1a0483@google.com>
 <20190721044615-mutt-send-email-mst@kernel.org>
 <75c43998-3a1c-676f-99ff-3d04663c3fcc@redhat.com>
 <20190722035657-mutt-send-email-mst@kernel.org>
 <cfcd330d-5f4a-835a-69f7-c342d5d0d52d@redhat.com>
 <20190723010156-mutt-send-email-mst@kernel.org>
 <124be1a2-1c53-8e65-0f06-ee2294710822@redhat.com>
 <20190723032800-mutt-send-email-mst@kernel.org>
 <e2e01a05-63d8-4388-2bcd-b2be3c865486@redhat.com>
 <20190723062842-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <025aa12a-c789-7eac-ba96-48e4dd3dd551@redhat.com>
Date: Tue, 23 Jul 2019 21:37:23 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190723062842-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Tue, 23 Jul 2019 13:37:48 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/23 下午6:42, Michael S. Tsirkin wrote:
> On Tue, Jul 23, 2019 at 04:42:19PM +0800, Jason Wang wrote:
>>> So how about this: do exactly what you propose but as a 2 patch series:
>>> start with the slow safe patch, and add then return uaddr optimizations
>>> on top. We can then more easily reason about whether they are safe.
>>
>> If you stick, I can do this.
> So I definitely don't insist but I'd like us to get back to where
> we know existing code is very safe (if not super fast) and
> optimizing from there.  Bugs happen but I'd like to see a bisect
> giving us "oh it's because of XYZ optimization" and not the
> general "it's somewhere within this driver" that we are getting
> now.


Syzbot has bisected to the commit of metadata acceleration in fact :)


>
> Maybe the way to do this is to revert for this release cycle
> and target the next one. What do you think?


I would try to fix the issues consider packed virtqueue which may use 
this for a good performance number. But if you insist, I'm ok to revert. 
Or maybe introduce a config option to disable it by default (almost all 
optimized could be ruled out).

Thanks

