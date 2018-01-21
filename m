Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E4BCA6B0033
	for <linux-mm@kvack.org>; Sun, 21 Jan 2018 01:50:49 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id r1so5547771pgt.19
        for <linux-mm@kvack.org>; Sat, 20 Jan 2018 22:50:49 -0800 (PST)
Received: from anholt.net (anholt.net. [50.246.234.109])
        by mx.google.com with ESMTP id x2si11669433pgq.223.2018.01.20.22.50.48
        for <linux-mm@kvack.org>;
        Sat, 20 Jan 2018 22:50:48 -0800 (PST)
From: Eric Anholt <eric@anholt.net>
Subject: Re: [RFC] Per file OOM badness
In-Reply-To: <8ab81340-f4f0-c2ed-6462-5f14102af1a9@daenzer.net>
References: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com> <20180118170006.GG6584@dhcp22.suse.cz> <20180118171355.GH6584@dhcp22.suse.cz> <87k1wfgcmb.fsf@anholt.net> <20180119082046.GL6584@dhcp22.suse.cz> <0cfaf256-928c-4cb8-8220-b8992592071b@amd.com> <a3f6dc22-fce2-4371-462a-a4898249cf61@daenzer.net> <11153f4f-8b9a-5780-6087-bc1e85459584@gmail.com> <8939a03e-8204-940b-dd69-be28f75a2492@daenzer.net> <8ab81340-f4f0-c2ed-6462-5f14102af1a9@daenzer.net>
Date: Sun, 21 Jan 2018 17:50:39 +1100
Message-ID: <87bmhnn1s0.fsf@anholt.net>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel =?utf-8?Q?D=C3=A4nzer?= <michel@daenzer.net>, christian.koenig@amd.com, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Michel D=C3=A4nzer <michel@daenzer.net> writes:

> On 2018-01-19 11:02 AM, Michel D=C3=A4nzer wrote:
>> On 2018-01-19 10:58 AM, Christian K=C3=B6nig wrote:
>>> Am 19.01.2018 um 10:32 schrieb Michel D=C3=A4nzer:
>>>> On 2018-01-19 09:39 AM, Christian K=C3=B6nig wrote:
>>>>> Am 19.01.2018 um 09:20 schrieb Michal Hocko:
>>>>>> OK, in that case I would propose a different approach. We already
>>>>>> have rss_stat. So why do not we simply add a new counter there
>>>>>> MM_KERNELPAGES and consider those in oom_badness? The rule would be
>>>>>> that such a memory is bound to the process life time. I guess we will
>>>>>> find more users for this later.
>>>>> I already tried that and the problem with that approach is that some
>>>>> buffers are not created by the application which actually uses them.
>>>>>
>>>>> For example X/Wayland is creating and handing out render buffers to
>>>>> application which want to use OpenGL.
>>>>>
>>>>> So the result is when you always account the application who created =
the
>>>>> buffer the OOM killer will certainly reap X/Wayland first. And that is
>>>>> exactly what we want to avoid here.
>>>> FWIW, what you describe is true with DRI2, but not with DRI3 or Wayland
>>>> anymore. With DRI3 and Wayland, buffers are allocated by the clients a=
nd
>>>> then shared with the X / Wayland server.
>>>
>>> Good point, when I initially looked at that problem DRI3 wasn't widely
>>> used yet.
>>>
>>>> Also, in all cases, the amount of memory allocated for buffers shared
>>>> between DRI/Wayland clients and the server should be relatively small
>>>> compared to the amount of memory allocated for buffers used only local=
ly
>>>> in the client, particularly for clients which create significant memory
>>>> pressure.
>>>
>>> That is unfortunately only partially true. When you have a single
>>> runaway application which tries to allocate everything it would indeed
>>> work as you described.
>>>
>>> But when I tested this a few years ago with X based desktop the
>>> applications which actually used most of the memory where Firefox and
>>> Thunderbird. Unfortunately they never got accounted for that.
>>>
>>> Now, on my current Wayland based desktop it actually doesn't look much
>>> better. Taking a look at radeon_gem_info/amdgpu_gem_info the majority of
>>> all memory was allocated either by gnome-shell or Xwayland.
>>=20
>> My guess would be this is due to pixmaps, which allow X clients to cause
>> the X server to allocate essentially unlimited amounts of memory. It's a
>> separate issue, which would require a different solution than what we're
>> discussing in this thread. Maybe something that would allow the X server
>> to tell the kernel that some of the memory it allocates is for the
>> client process.
>
> Of course, such a mechanism could probably be abused to incorrectly
> blame other processes for one's own memory consumption...
>
>
> I'm not sure if the pixmap issue can be solved for the OOM killer. It's
> an X design issue which is fixed with Wayland. So it's probably better
> to ignore it for this discussion.
>
> Also, I really think the issue with DRM buffers being shared between
> processes isn't significant for the OOM killer compared to DRM buffers
> only used in the same process that allocates them. So I suggest focusing
> on the latter.

Agreed.  The 95% case is non-shared buffers, so just don't account for
them and we'll have a solution good enough that we probably never need
to handle the shared case.  On the DRM side, removing buffers from the
accounting once they get shared would be easy.

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEE/JuuFDWp9/ZkuCBXtdYpNtH8nugFAlpkOD8ACgkQtdYpNtH8
nugEaQ//UVM3hHsL6oYdm13L94SLc4KIYzwAEKKRUUn8qCjrqun0tQew1C+Ue4+I
FzGYm5V4WjoiFZOAGlAhlKV0QV8W6OBwLEqTAuYtiKzSJDBqLxKf+Ay2VLVjbzYH
xpmjB+9abc+lpT3HQAshur6iy1zH9dvDdZdFh+yTzl2N2Atjuxbnowhbs1RidDbs
b7YWamcKdAdzQ2iwnY0cXRIt5qHPrhzPSpJLJRis3+u2xJGdTca9/LeNJOUMsLOW
L4ibg1MQ6zX816O86B4xhEmjcTDD2o+68ZiPEhnmmAon+/ee8ApVjFFPxtzae30v
051HEriXQeDutO0FreE9JJ7IiU8pG9BsqmfPlSUcb9kV2IZq7hLuFgXKT+ezg8Qz
2gn44sWjP4YvvSfxCCLMyTh1yuHaBM1aDFOVURSW/UdDsJwVhGYAb301udQjitkm
bCgakepd3NfZSYycfB/39TXipsMOoBJobe1mg8nFEDCkXWnBDMHl1fdRbB9Q8i7A
QONF7Nnk9y+oTRydXI+kh5opdIsdBS4IYnuAcXWvFq0+oTZzasxwlIczO50MkzUH
UvQoKa5XdVm9xBgMx3r/UL3Rg76Xvs1PkOnmt2tq0HXx1+P9CXMROPwin0sw0H6H
/5beGTalFNdATBCMiwfGNCtrIHLHPFMFxzr17C+cLEvflbrEL1Y=
=OrGX
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
