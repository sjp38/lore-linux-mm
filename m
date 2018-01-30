Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7B6536B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 05:48:11 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id q21so4070463lfa.14
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 02:48:11 -0800 (PST)
Received: from netline-mail3.netline.ch (mail.netline.ch. [148.251.143.178])
        by mx.google.com with ESMTP id u6si3503825lju.296.2018.01.30.02.48.09
        for <linux-mm@kvack.org>;
        Tue, 30 Jan 2018 02:48:09 -0800 (PST)
Subject: Re: [RFC] Per file OOM badness
References: <20180123153631.GR1526@dhcp22.suse.cz>
 <ccac4870-ced3-f169-17df-2ab5da468bf0@daenzer.net>
 <20180124092847.GI1526@dhcp22.suse.cz>
 <583f328e-ff46-c6a4-8548-064259995766@daenzer.net>
 <20180124110141.GA28465@dhcp22.suse.cz>
 <36b49523-792d-45f9-8617-32b6d9d77418@daenzer.net>
 <20180124115059.GC28465@dhcp22.suse.cz>
 <381a868c-78fd-d0d1-029e-a2cf4ab06d37@gmail.com>
 <20180130093145.GE25930@phenom.ffwll.local>
 <3db43c1a-59b8-af86-2b87-c783c629f512@daenzer.net>
 <20180130104216.GR25930@phenom.ffwll.local>
From: =?UTF-8?Q?Michel_D=c3=a4nzer?= <michel@daenzer.net>
Message-ID: <5c3f8061-d2d2-fa33-faac-cb95e0b2d44b@daenzer.net>
Date: Tue, 30 Jan 2018 11:48:06 +0100
MIME-Version: 1.0
In-Reply-To: <20180130104216.GR25930@phenom.ffwll.local>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: christian.koenig@amd.com, Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>
Cc: dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, amd-gfx@lists.freedesktop.org

On 2018-01-30 11:42 AM, Daniel Vetter wrote:
> On Tue, Jan 30, 2018 at 10:43:10AM +0100, Michel DA?nzer wrote:
>> On 2018-01-30 10:31 AM, Daniel Vetter wrote:
>>
>>> I guess a good first order approximation would be if we simply charge any
>>> newly allocated buffers to the process that created them, but that means
>>> hanging onto lots of mm_struct pointers since we want to make sure we then
>>> release those pages to the right mm again (since the process that drops
>>> the last ref might be a totally different one, depending upon how the
>>> buffers or DRM fd have been shared).
>>>
>>> Would it be ok to hang onto potentially arbitrary mmget references
>>> essentially forever? If that's ok I think we can do your process based
>>> account (minus a few minor inaccuracies for shared stuff perhaps, but no
>>> one cares about that).
>>
>> Honestly, I think you and Christian are overthinking this. Let's try
>> charging the memory to every process which shares a buffer, and go from
>> there.
> 
> I'm not concerned about wrongly accounting shared buffers (they don't
> matter), but imbalanced accounting. I.e. allocate a buffer in the client,
> share it, but then the compositor drops the last reference.

I don't think the order matters. The memory is "uncharged" in each
process when it drops its reference.


-- 
Earthling Michel DA?nzer               |               http://www.amd.com
Libre software enthusiast             |             Mesa and X developer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
