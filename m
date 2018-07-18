Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id E5A046B000E
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 14:39:51 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id i9-v6so3984241qtj.3
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 11:39:51 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id h195-v6si4174315qke.31.2018.07.18.11.39.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 11:39:50 -0700 (PDT)
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
References: <18c5cbfe-403b-bb2b-1d11-19d324ec6234@redhat.com>
 <1531336913.3260.18.camel@HansenPartnership.com>
 <4d49a270-23c9-529f-f544-65508b6b53cc@redhat.com>
 <1531411494.18255.6.camel@HansenPartnership.com>
 <20180712164932.GA3475@bombadil.infradead.org>
 <1531416080.18255.8.camel@HansenPartnership.com>
 <CA+55aFzfQz7c8pcMfLDaRNReNF2HaKJGoWpgB6caQjNAyjg-hA@mail.gmail.com>
 <1531425435.18255.17.camel@HansenPartnership.com>
 <20180713003614.GW2234@dastard> <20180716090901.GG17280@dhcp22.suse.cz>
 <20180716124115.GA7072@bombadil.infradead.org>
 <20180716164032.94e13f765c5f33c6022eca38@linux-foundation.org>
From: Waiman Long <longman@redhat.com>
Message-ID: <d37af7a4-b9a9-0928-eed0-10ab818d08c0@redhat.com>
Date: Wed, 18 Jul 2018 14:39:48 -0400
MIME-Version: 1.0
In-Reply-To: <20180716164032.94e13f765c5f33c6022eca38@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, Dave Chinner <david@fromorbit.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, Linus Torvalds <torvalds@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>

On 07/16/2018 07:40 PM, Andrew Morton wrote:
> On Mon, 16 Jul 2018 05:41:15 -0700 Matthew Wilcox <willy@infradead.org>=
 wrote:
>
>> On Mon, Jul 16, 2018 at 11:09:01AM +0200, Michal Hocko wrote:
>>> On Fri 13-07-18 10:36:14, Dave Chinner wrote:
>>> [...]
>>>> By limiting the number of negative dentries in this case, internal
>>>> slab fragmentation is reduced such that reclaim cost never gets out
>>>> of control. While it appears to "fix" the symptoms, it doesn't
>>>> address the underlying problem. It is a partial solution at best but=

>>>> at worst it's another opaque knob that nobody knows how or when to
>>>> tune.
>>> Would it help to put all the negative dentries into its own slab cach=
e?
>> Maybe the dcache should be more sensitive to its own needs.  In __d_al=
loc,
>> it could check whether there are a high proportion of negative dentrie=
s
>> and start recycling some existing negative dentries.
> Well, yes.
>
> The proposed patchset adds all this background reclaiming.  Problem is
> a) that background reclaiming sometimes can't keep up so a synchronous
> direct-reclaim was added on top and b) reclaiming dentries in the
> background will cause non-dentry-allocating tasks to suffer because of
> activity from the dentry-allocating tasks, which is inappropriate.

I have taken out the background reclaiming in the latest v7 patch for
the concern people have on duplicating the reclaim effort. We can always
add it back on later on if we want to.

> I expect a better design is something like
>
> __d_alloc()
> {
> 	...
> 	while (too many dentries)
> 		call the dcache shrinker
> 	...
> }
>
> and that's it.  This way we have a hard upper limit and only the tasks
> which are creating dentries suffer the cost.

Yes, that is certainly one way of doing it.

Cheers,
Longman
