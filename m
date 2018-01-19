Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id C73CF6B0038
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 10:07:50 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id m195so843730lfg.2
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 07:07:50 -0800 (PST)
Received: from netline-mail3.netline.ch (mail.netline.ch. [148.251.143.178])
        by mx.google.com with ESMTP id m3si4304644lfi.207.2018.01.19.07.07.48
        for <linux-mm@kvack.org>;
        Fri, 19 Jan 2018 07:07:48 -0800 (PST)
Subject: Re: [RFC] Per file OOM badness
From: =?UTF-8?Q?Michel_D=c3=a4nzer?= <michel@daenzer.net>
References: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
 <20180118170006.GG6584@dhcp22.suse.cz> <20180118171355.GH6584@dhcp22.suse.cz>
 <87k1wfgcmb.fsf@anholt.net> <20180119082046.GL6584@dhcp22.suse.cz>
 <0cfaf256-928c-4cb8-8220-b8992592071b@amd.com>
 <a3f6dc22-fce2-4371-462a-a4898249cf61@daenzer.net>
 <11153f4f-8b9a-5780-6087-bc1e85459584@gmail.com>
 <8939a03e-8204-940b-dd69-be28f75a2492@daenzer.net>
Message-ID: <8ab81340-f4f0-c2ed-6462-5f14102af1a9@daenzer.net>
Date: Fri, 19 Jan 2018 16:07:45 +0100
MIME-Version: 1.0
In-Reply-To: <8939a03e-8204-940b-dd69-be28f75a2492@daenzer.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: christian.koenig@amd.com, Michal Hocko <mhocko@kernel.org>, Eric Anholt <eric@anholt.net>
Cc: linux-mm@kvack.org, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org

On 2018-01-19 11:02 AM, Michel DA?nzer wrote:
> On 2018-01-19 10:58 AM, Christian KA?nig wrote:
>> Am 19.01.2018 um 10:32 schrieb Michel DA?nzer:
>>> On 2018-01-19 09:39 AM, Christian KA?nig wrote:
>>>> Am 19.01.2018 um 09:20 schrieb Michal Hocko:
>>>>> OK, in that case I would propose a different approach. We already
>>>>> have rss_stat. So why do not we simply add a new counter there
>>>>> MM_KERNELPAGES and consider those in oom_badness? The rule would be
>>>>> that such a memory is bound to the process life time. I guess we will
>>>>> find more users for this later.
>>>> I already tried that and the problem with that approach is that some
>>>> buffers are not created by the application which actually uses them.
>>>>
>>>> For example X/Wayland is creating and handing out render buffers to
>>>> application which want to use OpenGL.
>>>>
>>>> So the result is when you always account the application who created the
>>>> buffer the OOM killer will certainly reap X/Wayland first. And that is
>>>> exactly what we want to avoid here.
>>> FWIW, what you describe is true with DRI2, but not with DRI3 or Wayland
>>> anymore. With DRI3 and Wayland, buffers are allocated by the clients and
>>> then shared with the X / Wayland server.
>>
>> Good point, when I initially looked at that problem DRI3 wasn't widely
>> used yet.
>>
>>> Also, in all cases, the amount of memory allocated for buffers shared
>>> between DRI/Wayland clients and the server should be relatively small
>>> compared to the amount of memory allocated for buffers used only locally
>>> in the client, particularly for clients which create significant memory
>>> pressure.
>>
>> That is unfortunately only partially true. When you have a single
>> runaway application which tries to allocate everything it would indeed
>> work as you described.
>>
>> But when I tested this a few years ago with X based desktop the
>> applications which actually used most of the memory where Firefox and
>> Thunderbird. Unfortunately they never got accounted for that.
>>
>> Now, on my current Wayland based desktop it actually doesn't look much
>> better. Taking a look at radeon_gem_info/amdgpu_gem_info the majority of
>> all memory was allocated either by gnome-shell or Xwayland.
> 
> My guess would be this is due to pixmaps, which allow X clients to cause
> the X server to allocate essentially unlimited amounts of memory. It's a
> separate issue, which would require a different solution than what we're
> discussing in this thread. Maybe something that would allow the X server
> to tell the kernel that some of the memory it allocates is for the
> client process.

Of course, such a mechanism could probably be abused to incorrectly
blame other processes for one's own memory consumption...


I'm not sure if the pixmap issue can be solved for the OOM killer. It's
an X design issue which is fixed with Wayland. So it's probably better
to ignore it for this discussion.

Also, I really think the issue with DRM buffers being shared between
processes isn't significant for the OOM killer compared to DRM buffers
only used in the same process that allocates them. So I suggest focusing
on the latter.


-- 
Earthling Michel DA?nzer               |               http://www.amd.com
Libre software enthusiast             |             Mesa and X developer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
