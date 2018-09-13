Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id EF4048E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 07:11:38 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id u12-v6so4612580wrc.1
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 04:11:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n17-v6si4782193edf.195.2018.09.13.04.11.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Sep 2018 04:11:37 -0700 (PDT)
Date: Thu, 13 Sep 2018 13:11:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] selinux: Add __GFP_NOWARN to allocation at str_read()
Message-ID: <20180913111135.GA21006@dhcp22.suse.cz>
References: <000000000000038dab0575476b73@google.com>
 <f3bcebc6-47a7-518e-70f7-c7e167621841@I-love.SAKURA.ne.jp>
 <CAHC9VhT-Thu6KppC-MWzqkB7R1CaQA9DWXOQnG0b2uS9+rvzoA@mail.gmail.com>
 <ea29a8bf-95b2-91d2-043b-ed73c9023166@i-love.sakura.ne.jp>
 <9d685700-bc5c-9c2f-7795-56f488d2ea38@sony.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <9d685700-bc5c-9c2f-7795-56f488d2ea38@sony.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter enderborg <peter.enderborg@sony.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Paul Moore <paul@paul-moore.com>, selinux@tycho.nsa.gov, syzbot+ac488b9811036cea7ea0@syzkaller.appspotmail.com, Eric Paris <eparis@parisplace.org>, linux-kernel@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>, syzkaller-bugs@googlegroups.com, linux-mm <linux-mm@kvack.org>

On Thu 13-09-18 09:12:04, peter enderborg wrote:
> On 09/13/2018 08:26 AM, Tetsuo Handa wrote:
> > On 2018/09/13 12:02, Paul Moore wrote:
> >> On Fri, Sep 7, 2018 at 12:43 PM Tetsuo Handa
> >> <penguin-kernel@i-love.sakura.ne.jp> wrote:
> >>> syzbot is hitting warning at str_read() [1] because len parameter can
> >>> become larger than KMALLOC_MAX_SIZE. We don't need to emit warning for
> >>> this case.
> >>>
> >>> [1] https://syzkaller.appspot.com/bug?id=7f2f5aad79ea8663c296a2eedb81978401a908f0
> >>>
> >>> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> >>> Reported-by: syzbot <syzbot+ac488b9811036cea7ea0@syzkaller.appspotmail.com>
> >>> ---
> >>>  security/selinux/ss/policydb.c | 2 +-
> >>>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>>
> >>> diff --git a/security/selinux/ss/policydb.c b/security/selinux/ss/policydb.c
> >>> index e9394e7..f4eadd3 100644
> >>> --- a/security/selinux/ss/policydb.c
> >>> +++ b/security/selinux/ss/policydb.c
> >>> @@ -1101,7 +1101,7 @@ static int str_read(char **strp, gfp_t flags, void *fp, u32 len)
> >>>         if ((len == 0) || (len == (u32)-1))
> >>>                 return -EINVAL;
> >>>
> >>> -       str = kmalloc(len + 1, flags);
> >>> +       str = kmalloc(len + 1, flags | __GFP_NOWARN);
> >>>         if (!str)
> >>>                 return -ENOMEM;
> >> Thanks for the patch.
> >>
> >> My eyes are starting to glaze over a bit chasing down all of the
> >> different kmalloc() code paths trying to ensure that this always does
> >> the right thing based on size of the allocation and the different slab
> >> allocators ... are we sure that this will always return NULL when (len
> >> + 1) is greater than KMALLOC_MAX_SIZE for the different slab allocator
> >> configurations?
> >>
> > Yes, for (len + 1) cannot become 0 (which causes kmalloc() to return
> > ZERO_SIZE_PTR) due to (len == (u32)-1) check above.
> >
> > The only concern would be whether you want allocation failure messages.
> > I assumed you don't need it because we are returning -ENOMEM to the caller.
> >
> Would it not be better with
> 
>     char *str;
> 
>     if ((len == 0) || (len == (u32)-1) || (len >= KMALLOC_MAX_SIZE))
>         return -EINVAL;
> 
>     str = kmalloc(len + 1, flags);
>     if (!str)
>         return -ENOMEM;

I strongly suspect that you want kvmalloc rather than kmalloc here. The
larger the request the more likely is the allocation to fail.

I am not familiar with the code but I assume this is a root only
interface so we don't have to worry about nasty users scenario.

-- 
Michal Hocko
SUSE Labs
