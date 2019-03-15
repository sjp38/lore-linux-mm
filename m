Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A7DFC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 16:10:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C163218AC
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 16:10:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="hKHmU445"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C163218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE65B6B028C; Fri, 15 Mar 2019 12:10:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B6BC56B028E; Fri, 15 Mar 2019 12:10:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A35256B028F; Fri, 15 Mar 2019 12:10:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id 627236B028C
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 12:10:01 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id k129so3619749vke.3
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 09:10:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=kE5A+CZCQ970cuz5dKKKfTnoUsaz55mW0Rz8hAw/vKE=;
        b=Ioh9MqqU3zcsnJmaMZxwuZBZny5tQlwwopaeAsWYyEC/oHO06w2ZbIjZVEk5jZx/R+
         QRMCL4aZXHZSFGLKnkVUCYV24xL0AqcYqjSZmjCqs+c7PIbxEgP4tQb9+KHjUsXn2ApI
         ciKlXIv0C88/lmCqD4XhibdTxGhmoyczTiqjIn7aBVQKBUzOroT3oS0u41k/fuLlTtp7
         Z3xU8SNXssRDj92q8u56bF5E7F7tF8SaHU91xtWEr+1TJdFOboIUz09X1Si/iJU9WJpH
         cSk+u1p5bpI8spuJzR8iMuFHuJO8e5DiiVIAXydoGC5AEzhFELCzg6iq3tXB+b0pbmQ2
         JsRg==
X-Gm-Message-State: APjAAAW1keBkdnSdsBjVUfLZIeagsIwuvUHixqoVQEgmm8s5Jhe+Tmgk
	lDyR5z5MQAWxbYtEiXy6+W9mmvFgKq/wpJXrxLqeZAoP3Mk0qqUPIFxVQWtQVxfgWKNJLhr/Hf9
	GhuCDbCQNyGiZUS6KefmRwhRBKMckuqOoDQAPTj6D75XdTcT5m4bZOeZdQZm+/xDLNw==
X-Received: by 2002:a1f:804c:: with SMTP id b73mr2480185vkd.90.1552666201099;
        Fri, 15 Mar 2019 09:10:01 -0700 (PDT)
X-Received: by 2002:a1f:804c:: with SMTP id b73mr2480127vkd.90.1552666200037;
        Fri, 15 Mar 2019 09:10:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552666200; cv=none;
        d=google.com; s=arc-20160816;
        b=x7yI0ug/ZbxI1Feez0nNmY3a38XhK5fsjzpXCbwoLCSKXXDZEiESM0YyPXp1IuDOTo
         7pQVCJ+qE4dKMZZAvKtlbzuUOv1BT9zT0XM1KGYz59QG3D/awtDIj+fSheJoOAQXDGJ+
         JsCqhZs0qo0EZdtXXFtbR/r/YIL6nVAL7+ocvjEcxx9/JxmyGeUwK1sxdmMJnNFho/eC
         T615wWPojHnJ0t+mlr9pLerVH79DkKaQODMXDgoqvu4TCqX+l93IslEFz/S7UhG+I+MF
         fFFH7UBHcl6g4BkqTDWO0uRIdcjT1IstN2zgVEjD9Pdfuu4YEX0lfT04O3xNhBGV8uyw
         R35Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=kE5A+CZCQ970cuz5dKKKfTnoUsaz55mW0Rz8hAw/vKE=;
        b=Xpr+uq+j40ht6CBKRADQCTcGVbzjhjV4dAcGI+VlWFNZKUloAqbnQrWpOnWgn7gye9
         Tqy19cQZqqeOgXViZTQ5yIkPhZxRePku5VorDGZ587oNeT5ZFiRXBOn3j6sdoCYpTEWv
         I7NIfiN2h423NMUkRymwGFBjG0u8sPxMVJtVDE6EQQzROO6bGF+McK9bBI/EqZ1f9ARq
         rXVl75Csm6XIkDA2Igv4pLyfyYrL/dhPX3dneEuJp449CrwD2D/r2mbkhFh+s5W0ZDc+
         +vZL2vuIQPdOSlnjR6amw12XnpsXytsREA97LJ21EBwOqHdn/6OpqTipRl60L07jT1Wj
         9ySQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=hKHmU445;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 61sor31994uay.34.2019.03.15.09.09.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Mar 2019 09:10:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=hKHmU445;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=kE5A+CZCQ970cuz5dKKKfTnoUsaz55mW0Rz8hAw/vKE=;
        b=hKHmU445IW/COhLh4C9icWVxuotJ3n1hCtm7Gll2wbtPW4oq5SvQlNfsGLiOslggPx
         rRw566RrEYUaSv3edGRRW9MQlE5W4+P4BUQWyE/f7O72f0uo/ZBhU4H5d4B68siXDRbD
         lEjpw9QGwmZcXVVIIqjXAyY0txLfCl7Z36WBI=
X-Google-Smtp-Source: APXvYqxFuHXBvFC0qIvj5hBc8qd7ToueMYbKIMgXvMlTC9fX1XTEu1srPRBVdxKBgGK8T4eofMcK8w==
X-Received: by 2002:ab0:4a8d:: with SMTP id s13mr106994uae.122.1552666198447;
        Fri, 15 Mar 2019 09:09:58 -0700 (PDT)
Received: from mail-vs1-f52.google.com (mail-vs1-f52.google.com. [209.85.217.52])
        by smtp.gmail.com with ESMTPSA id j28sm484466vsl.10.2019.03.15.09.09.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Mar 2019 09:09:57 -0700 (PDT)
Received: by mail-vs1-f52.google.com with SMTP id b8so5692991vsq.11
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 09:09:57 -0700 (PDT)
X-Received: by 2002:a67:fa45:: with SMTP id j5mr2431791vsq.48.1552666196638;
 Fri, 15 Mar 2019 09:09:56 -0700 (PDT)
MIME-Version: 1.0
References: <20190311093701.15734-1-peterx@redhat.com> <58e63635-fc1b-cb53-a4d1-237e6b8b7236@oracle.com>
 <20190313060023.GD2433@xz-x1> <3714d120-64e3-702e-6eef-4ef253bdb66d@redhat.com>
 <20190313185230.GH25147@redhat.com> <1934896481.7779933.1552504348591.JavaMail.zimbra@redhat.com>
 <20190313234458.GJ25147@redhat.com> <298b9469-abd2-b02b-5c71-529b8976a46c@redhat.com>
 <20190314161630.GS25147@redhat.com>
In-Reply-To: <20190314161630.GS25147@redhat.com>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 15 Mar 2019 09:09:45 -0700
X-Gmail-Original-Message-ID: <CAGXu5j+WwcYTavVRp2M1AashdCwf2YX=RmUtO_5bHXPK9iZhGQ@mail.gmail.com>
Message-ID: <CAGXu5j+WwcYTavVRp2M1AashdCwf2YX=RmUtO_5bHXPK9iZhGQ@mail.gmail.com>
Subject: Re: [PATCH 0/3] userfaultfd: allow to forbid unprivileged users
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>, Peter Xu <peterx@redhat.com>, 
	Mike Kravetz <mike.kravetz@oracle.com>, LKML <linux-kernel@vger.kernel.org>, 
	Hugh Dickins <hughd@google.com>, Luis Chamberlain <mcgrof@kernel.org>, 
	Maxime Coquelin <maxime.coquelin@redhat.com>, KVM <kvm@vger.kernel.org>, 
	Jerome Glisse <jglisse@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Martin Cracauer <cracauer@cons.org>, 
	Denis Plotnikov <dplotnikov@virtuozzo.com>, Linux-MM <linux-mm@kvack.org>, 
	Marty McFadden <mcfadden8@llnl.gov>, Maya Gokhale <gokhale2@llnl.gov>, 
	Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, 
	"Kirill A . Shutemov" <kirill@shutemov.name>, 
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, 
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 14, 2019 at 9:16 AM Andrea Arcangeli <aarcange@redhat.com> wrote:
> So this will be for who's paranoid and prefers to disable userfaultfd
> as a whole as an hardening feature like the bpf sysctl allows: it will
> allow to block uffd syscall without having to rebuild the kernel with
> CONFIG_USERFAULTFD=n in environments where seccomp cannot be easily
> enabled (i.e. without requiring userland changes).
>
> That's very fine with me, but then it wasn't me complaining in the
> first place. Kees?

I'm fine with a boolean. I just wanted to find a way to disable at
runtime (so distro users had it available to them).

-- 
Kees Cook

