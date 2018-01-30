Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id C0F796B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 06:34:22 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id m79so4079385lfm.17
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 03:34:22 -0800 (PST)
Received: from netline-mail3.netline.ch (mail.netline.ch. [148.251.143.178])
        by mx.google.com with ESMTP id r11si985029ljd.357.2018.01.30.03.34.20
        for <linux-mm@kvack.org>;
        Tue, 30 Jan 2018 03:34:21 -0800 (PST)
Subject: Re: [RFC] Per file OOM badness
References: <20180118170006.GG6584@dhcp22.suse.cz>
 <20180123152659.GA21817@castle.DHCP.thefacebook.com>
 <20180123153631.GR1526@dhcp22.suse.cz>
 <ccac4870-ced3-f169-17df-2ab5da468bf0@daenzer.net>
 <20180124092847.GI1526@dhcp22.suse.cz>
 <583f328e-ff46-c6a4-8548-064259995766@daenzer.net>
 <20180124110141.GA28465@dhcp22.suse.cz>
 <36b49523-792d-45f9-8617-32b6d9d77418@daenzer.net>
 <20180124115059.GC28465@dhcp22.suse.cz>
 <381a868c-78fd-d0d1-029e-a2cf4ab06d37@gmail.com>
 <20180130093145.GE25930@phenom.ffwll.local>
 <3db43c1a-59b8-af86-2b87-c783c629f512@daenzer.net>
 <3026d8c5-9313-cb8b-91ef-09c02baf27db@amd.com>
 <445628d3-677c-a9f8-171f-7d74a603c61d@daenzer.net>
 <dce6d244-36c7-7452-97f5-7437bd78cfcc@gmail.com>
From: =?UTF-8?Q?Michel_D=c3=a4nzer?= <michel@daenzer.net>
Message-ID: <e511ba10-7032-36cc-f22c-2f6bb05f9f6e@daenzer.net>
Date: Tue, 30 Jan 2018 12:34:18 +0100
MIME-Version: 1.0
In-Reply-To: <dce6d244-36c7-7452-97f5-7437bd78cfcc@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: christian.koenig@amd.com, Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org

On 2018-01-30 12:28 PM, Christian KA?nig wrote:
> Am 30.01.2018 um 12:02 schrieb Michel DA?nzer:
>> On 2018-01-30 11:40 AM, Christian KA?nig wrote:
>>> Am 30.01.2018 um 10:43 schrieb Michel DA?nzer:
>>>> [SNIP]
>>>>> Would it be ok to hang onto potentially arbitrary mmget references
>>>>> essentially forever? If that's ok I think we can do your process based
>>>>> account (minus a few minor inaccuracies for shared stuff perhaps,
>>>>> but no
>>>>> one cares about that).
>>>> Honestly, I think you and Christian are overthinking this. Let's try
>>>> charging the memory to every process which shares a buffer, and go from
>>>> there.
>>> My problem is that this needs to be bullet prove.
>>>
>>> For example imagine an application which allocates a lot of BOs, then
>>> calls fork() and let the parent process die. The file descriptor lives
>>> on in the child process, but the memory is not accounted against the
>>> child.
>> What exactly are you referring to by "the file descriptor" here?
> 
> The file descriptor used to identify the connection to the driver. In
> other words our drm_file structure in the kernel.
> 
>> What happens to BO handles in general in this case? If both parent and
>> child process keep the same handle for the same BO, one of them
>> destroying the handle will result in the other one not being able to use
>> it anymore either, won't it?
> Correct.
> 
> That usage is actually not useful at all, but we already had
> applications which did exactly that by accident.
> 
> Not to mention that somebody could do it on purpose.

Can we just prevent child processes from using their parent's DRM file
descriptors altogether? Allowing it seems like a bad idea all around.


-- 
Earthling Michel DA?nzer               |               http://www.amd.com
Libre software enthusiast             |             Mesa and X developer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
