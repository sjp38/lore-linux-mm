Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 15B9B6B0069
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 11:30:39 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id b186so23271978vkb.0
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 08:30:39 -0700 (PDT)
Received: from mail-vk0-x230.google.com (mail-vk0-x230.google.com. [2607:f8b0:400c:c05::230])
        by mx.google.com with ESMTPS id h86si20027653vkc.66.2016.10.19.08.30.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 08:30:35 -0700 (PDT)
Received: by mail-vk0-x230.google.com with SMTP id 83so31025403vkd.0
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 08:30:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87k2d5nytz.fsf_-_@xmission.com>
References: <87twcbq696.fsf@x220.int.ebiederm.org> <20161018135031.GB13117@dhcp22.suse.cz>
 <8737jt903u.fsf@xmission.com> <20161018150507.GP14666@pc.thejh.net>
 <87twc9656s.fsf@xmission.com> <20161018191206.GA1210@laptop.thejh.net>
 <87r37dnz74.fsf@xmission.com> <87k2d5nytz.fsf_-_@xmission.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 19 Oct 2016 08:30:14 -0700
Message-ID: <CALCETrU4SZYUEPrv4JkpUpA+0sZ=EirZRftRDp+a5hce5E7HgA@mail.gmail.com>
Subject: Re: [REVIEW][PATCH] exec: Don't exec files the userns root can not read.
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Jann Horn <jann@thejh.net>, Michal Hocko <mhocko@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>

On Tue, Oct 18, 2016 at 2:15 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
>
> When the user namespace support was merged the need to prevent
> ptracing an executable that is not readable was overlooked.

Before getting too excited about this fix, isn't there a much bigger
hole that's been there forever?  Simply ptrace yourself, exec the
program, and then dump the program out.  A program that really wants
to be unreadable should have a stub: the stub is setuid and readable,
but all the stub does is to exec the real program, and the real
program should have mode 0500 or similar.

ISTM the "right" check would be to enforce that the program's new
creds can read the program, but that will break backwards
compatibility.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
