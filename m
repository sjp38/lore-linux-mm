Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7ED2D6B0069
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 01:02:01 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id r12so18181479pgu.9
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 22:02:01 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id i4si5735515pgr.266.2017.11.22.22.01.59
        for <linux-mm@kvack.org>;
        Wed, 22 Nov 2017 22:02:00 -0800 (PST)
Date: Thu, 23 Nov 2017 15:07:38 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0/5] mm/kasan: advanced check
Message-ID: <20171123060738.GB31720@js1304-P5Q-DELUXE>
References: <20171117223043.7277-1-wen.gang.wang@oracle.com>
 <CACT4Y+ZkC8R1vL+=j4Ordr2-4BWAc8Um+hdxPPWS6_DFi58ZJA@mail.gmail.com>
 <20171120015000.GA13507@js1304-P5Q-DELUXE>
 <8bdd114f-4bf1-e60d-eb78-af67f6c74abc@oracle.com>
 <20171122043027.GA24912@js1304-P5Q-DELUXE>
 <CACT4Y+ZawvvJFBu7J2EXz8tWpcavMhKWGvuGcYow91WxAPM+Og@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+ZawvvJFBu7J2EXz8tWpcavMhKWGvuGcYow91WxAPM+Og@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Wengang <wen.gang.wang@oracle.com>, Linux-MM <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>

On Wed, Nov 22, 2017 at 09:51:11AM +0100, Dmitry Vyukov wrote:
> On Wed, Nov 22, 2017 at 5:30 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> > On Mon, Nov 20, 2017 at 11:56:05AM -0800, Wengang wrote:
> >>
> >>
> >> On 11/19/2017 05:50 PM, Joonsoo Kim wrote:
> >> >On Fri, Nov 17, 2017 at 11:56:21PM +0100, Dmitry Vyukov wrote:
> >> >>On Fri, Nov 17, 2017 at 11:30 PM, Wengang Wang <wen.gang.wang@oracle.com> wrote:
> >> >>>Kasan advanced check, I'm going to add this feature.
> >> >>>Currently Kasan provide the detection of use-after-free and out-of-bounds
> >> >>>problems. It is not able to find the overwrite-on-allocated-memory issue.
> >> >>>We sometimes hit this kind of issue: We have a messed up structure
> >> >>>(usually dynamially allocated), some of the fields in the structure were
> >> >>>overwritten with unreasaonable values. And kernel may panic due to those
> >> >>>overeritten values. We know those fields were overwritten somehow, but we
> >> >>>have no easy way to find out which path did the overwritten. The advanced
> >> >>>check wants to help in this scenario.
> >> >>>
> >> >>>The idea is to define the memory owner. When write accesses come from
> >> >>>non-owner, error should be reported. Normally the write accesses on a given
> >> >>>structure happen in only several or a dozen of functions if the structure
> >> >>>is not that complicated. We call those functions "allowed functions".
> >> >>>The work of defining the owner and binding memory to owner is expected to
> >> >>>be done by the memory consumer. In the above case, memory consume register
> >> >>>the owner as the functions which have write accesses to the structure then
> >> >>>bind all the structures to the owner. Then kasan will do the "owner check"
> >> >>>after the basic checks.
> >> >>>
> >> >>>As implementation, kasan provides a API to it's user to register their
> >> >>>allowed functions. The API returns a token to users.  At run time, users
> >> >>>bind the memory ranges they are interested in to the check they registered.
> >> >>>Kasan then checks the bound memory ranges with the allowed functions.
> >> >>>
> >> >>>
> >> >>>Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
> >> >Hello, Wengang.
> >> >
> >> >Nice idea. I also think that we need this kind of debugging tool. It's very
> >> >hard to detect overwritten bugs.
> >> >
> >> >In fact, I made a quite similar tool, valid access checker (A.K.A.
> >> >vchecker). See the following link.
> >> >
> >> >https://github.com/JoonsooKim/linux/tree/vchecker-master-v0.3-next-20170106
> >> >
> >> >Vchecker has some advanced features compared to yours.
> >> >
> >> >1. Target object can be choosen at runtime by debugfs. It doesn't
> >> >require re-compile to register the target object.
> >> Hi Joonsoo, good to know you are also interested in this!
> >>
> >> Yes, if can be choosen via debugfs, it doesn't need re-compile.
> >> Well, I wonder what do you expect to be chosen from use space?
> >
> > As you mentioned somewhere, this tool can be used when we find the
> > overwritten happend on some particular victims. I assumes that most of
> > the problem would happen on slab objects and userspace can choose the
> > target slab cache via debugfs interface of the vchecker.
> 
> 
> Most objects are allocated from kmalloc slabs. And this feature can't
> work for all objects allocated from a kmalloc slab. I think checks
> needs to be tied to allocation sites.

I think that this problem can be easily solved by introducing filter.
If the user specify interesting kmalloc() caller via debugfs, vchecker
can distinguish the interesting objects. Manual code addition would
not be needed. I will implement this feature and submit soon.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
