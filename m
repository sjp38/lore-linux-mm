Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3DCA4828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 09:33:42 -0500 (EST)
Received: by mail-ob0-f179.google.com with SMTP id ba1so327826786obb.3
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 06:33:42 -0800 (PST)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id r8si16484114oey.99.2016.01.07.06.33.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jan 2016 06:33:41 -0800 (PST)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0O0L00MWW741SCA0@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 07 Jan 2016 14:33:37 +0000 (GMT)
Content-transfer-encoding: 8BIT
Subject: Re: [PATCH 1/4] drm: add support for generic zpos property
References: <1451998373-13708-1-git-send-email-m.szyprowski@samsung.com>
 <1451998373-13708-2-git-send-email-m.szyprowski@samsung.com>
 <20160107135922.GO8076@phenom.ffwll.local>
From: Marek Szyprowski <m.szyprowski@samsung.com>
Message-id: <568E7740.8090709@samsung.com>
Date: Thu, 07 Jan 2016 15:33:36 +0100
In-reply-to: <20160107135922.GO8076@phenom.ffwll.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-gfx@lists.freedesktop.org, Linux MM <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jens Axboe <jens.axboe@oracle.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

Hello,

On 2016-01-07 14:59, Daniel Vetter wrote:
> On Tue, Jan 05, 2016 at 01:52:50PM +0100, Marek Szyprowski wrote:
>> This patch adds support for generic plane's zpos property property with
>> well-defined semantics:
>> - added zpos properties to drm core and plane state structures
>> - added helpers for normalizing zpos properties of given set of planes
>> - well defined semantics: planes are sorted by zpos values and then plane
>>    id value if zpos equals
>>
>> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> lgtm I think. Longer-term we want to think whether we don't want to
> extract such extensions into separate files, and push the kerneldoc into
> an overview DOC: section in there. Just to keep things more closely
> together. Benjamin with drm/sti also needs this, so cc'ing him.

Besides sti and exynos, zpos is also already implemented in rcar, mdp5 
and omap
drivers. I'm not sure what should be done in case of omap, which uses 
this property
with different name ("zorder" instead of "zpos").

>> ---
>>   Documentation/DocBook/gpu.tmpl      | 14 ++++++++--
>>   drivers/gpu/drm/drm_atomic.c        |  4 +++
>>   drivers/gpu/drm/drm_atomic_helper.c | 52 +++++++++++++++++++++++++++++++++++++
>>   drivers/gpu/drm/drm_crtc.c          | 13 ++++++++++
>>   include/drm/drm_atomic_helper.h     |  2 ++
>>   include/drm/drm_crtc.h              | 13 ++++++++++
>>   6 files changed, 96 insertions(+), 2 deletions(-)
>>
>> diff --git a/Documentation/DocBook/gpu.tmpl b/Documentation/DocBook/gpu.tmpl
>> index 6c6e81a9eaf4..e81acd999891 100644
>> --- a/Documentation/DocBook/gpu.tmpl
>> +++ b/Documentation/DocBook/gpu.tmpl
>> @@ -2004,7 +2004,7 @@ void intel_crt_init(struct drm_device *dev)
>>   	<td valign="top" >Description/Restrictions</td>
>>   	</tr>
>>   	<tr>
>> -	<td rowspan="37" valign="top" >DRM</td>
>> +	<td rowspan="38" valign="top" >DRM</td>
>>   	<td valign="top" >Generic</td>
>>   	<td valign="top" >a??rotationa??</td>
>>   	<td valign="top" >BITMASK</td>
>> @@ -2256,7 +2256,7 @@ void intel_crt_init(struct drm_device *dev)
>>   	<td valign="top" >property to suggest an Y offset for a connector</td>
>>   	</tr>
>>   	<tr>
>> -	<td rowspan="3" valign="top" >Optional</td>
>> +	<td rowspan="4" valign="top" >Optional</td>
>>   	<td valign="top" >a??scaling modea??</td>
>>   	<td valign="top" >ENUM</td>
>>   	<td valign="top" >{ "None", "Full", "Center", "Full aspect" }</td>
>> @@ -2280,6 +2280,16 @@ void intel_crt_init(struct drm_device *dev)
>>   	<td valign="top" >TBD</td>
>>   	</tr>
>>   	<tr>
>> +	<td valign="top" > "zpos" </td>
>> +	<td valign="top" >RANGE</td>
>> +	<td valign="top" >Min=0, Max=255</td>
>> +	<td valign="top" >Plane</td>
>> +	<td valign="top" >Plane's 'z' position during blending (0 for background, 255 for frontmost).
>> +		If two planes assigned to same CRTC have equal zpos values, the plane with higher plane
>> +		id is treated as closer to front. Can be IMMUTABLE if driver doesn't support changing
>> +		plane's order.</td>
>> +	</tr>
>> +	<tr>
>>   	<td rowspan="20" valign="top" >i915</td>
>>   	<td rowspan="2" valign="top" >Generic</td>
>>   	<td valign="top" >"Broadcast RGB"</td>
>> diff --git a/drivers/gpu/drm/drm_atomic.c b/drivers/gpu/drm/drm_atomic.c
>> index 6a21e5c378c1..97bb069cb6a3 100644
>> --- a/drivers/gpu/drm/drm_atomic.c
>> +++ b/drivers/gpu/drm/drm_atomic.c
>> @@ -614,6 +614,8 @@ int drm_atomic_plane_set_property(struct drm_plane *plane,
>>   		state->src_h = val;
>>   	} else if (property == config->rotation_property) {
>>   		state->rotation = val;
>> +	} else if (property == config->zpos_property) {
>> +		state->zpos = val;
>>   	} else if (plane->funcs->atomic_set_property) {
>>   		return plane->funcs->atomic_set_property(plane, state,
>>   				property, val);
>> @@ -670,6 +672,8 @@ drm_atomic_plane_get_property(struct drm_plane *plane,
>>   		*val = state->src_h;
>>   	} else if (property == config->rotation_property) {
>>   		*val = state->rotation;
>> +	} else if (property == config->zpos_property) {
>> +		*val = state->zpos;
>>   	} else if (plane->funcs->atomic_get_property) {
>>   		return plane->funcs->atomic_get_property(plane, state, property, val);
>>   	} else {
>> diff --git a/drivers/gpu/drm/drm_atomic_helper.c b/drivers/gpu/drm/drm_atomic_helper.c
>> index 268d37f26960..de3ca33eb696 100644
>> --- a/drivers/gpu/drm/drm_atomic_helper.c
>> +++ b/drivers/gpu/drm/drm_atomic_helper.c
>> @@ -31,6 +31,7 @@
>>   #include <drm/drm_crtc_helper.h>
>>   #include <drm/drm_atomic_helper.h>
>>   #include <linux/fence.h>
>> +#include <linux/sort.h>
>>   
>>   /**
>>    * DOC: overview
>> @@ -2781,3 +2782,54 @@ void drm_atomic_helper_connector_destroy_state(struct drm_connector *connector,
>>   	kfree(state);
>>   }
>>   EXPORT_SYMBOL(drm_atomic_helper_connector_destroy_state);
>> +
>> +/**
>> + * __drm_atomic_helper_plane_zpos_cmp - compare zpos value of two planes
>> + * @a: pointer to first plane
>> + * @b: pointer to second plane
> Generally we don't do kerneldoc for non-exported functions. If you want
> just keep the text itself as a comment, or better move it into the
> official interface docs for drm_atomic_helper_normalize_zpos().

okay

>> + *
>> + * This function is used for comparing two planes while sorting them to assign
>> + * a normalized zpos values. Planes are compared first by their zpos values,
>> + * then in case they equal, by plane id.
>> + */
>> +static int __drm_atomic_helper_plane_zpos_cmp(const void *a, const void *b)
>> +{
>> +	const struct drm_plane *pa = *(struct drm_plane **)a;
>> +	const struct drm_plane *pb = *(struct drm_plane **)b;
>> +	int zpos_a = 0, zpos_b = 0;
>> +
>> +	if (pa->state)
>> +		zpos_a = pa->state->zpos << 16;
>> +	if (pb->state)
>> +		zpos_b = pb->state->zpos << 16;
>> +
>> +	zpos_a += pa->base.id;
>> +	zpos_b += pb->base.id;
>> +
>> +	return zpos_a - zpos_b;
>> +}
>> +
>> +/**
>> + * drm_atomic_helper_normalize_zpos - calculate normalized zpos values
>> + * @planes: arrays of pointer to planes to consider for normalization
>> + * @count: number of planes in the above array
>> + *
>> + * This function takes arrays of pointers to planes and calculates normalized
>> + * zpos value for them taking into account each planes[i]->state->zpos value
>> + * and plane's id (if zpos equals). The plane[i]->state->normalized_zpos is
>> + * then filled with uniqe values from 0 to count-1.
>> + * Note: a side effect of this function is the fact that the planes array will
>> + * be modified (sorted). It is up to the called to construct planes array with
>> + * all planes that have been assigned to given crtc.
>> + */
>> +void drm_atomic_helper_normalize_zpos(struct drm_plane *planes[], int count)
>> +{
>> +	int i;
>> +
>> +	sort(planes, count, sizeof(struct drm_plane *),
>> +	     __drm_atomic_helper_plane_zpos_cmp, NULL);
>> +	for (i = 0; i < count; i++)
>> +		if (planes[i]->state)
>> +			planes[i]->state->normalized_zpos = i;
>> +}
>> +EXPORT_SYMBOL(drm_atomic_helper_normalize_zpos);
>> diff --git a/drivers/gpu/drm/drm_crtc.c b/drivers/gpu/drm/drm_crtc.c
>> index 62fa95fa5471..51474ea179f6 100644
>> --- a/drivers/gpu/drm/drm_crtc.c
>> +++ b/drivers/gpu/drm/drm_crtc.c
>> @@ -5879,6 +5879,19 @@ struct drm_property *drm_mode_create_rotation_property(struct drm_device *dev,
>>   }
>>   EXPORT_SYMBOL(drm_mode_create_rotation_property);
>>   
> Please add minimal kerneldoc for these two, with the suggestions that
> drivers should use drm_atomic_helper_normalize_zpos(). Also, I'd
> duplicated the semantic definition here (and explain why immutable
> exists) from the gpu.tmpl table.
>
>> +struct drm_property *drm_plane_create_zpos_property(struct drm_device *dev)
>> +{
>> +	return drm_property_create_range(dev, 0, "zpos", 0, 255);
> The zpos property should be stored in dev_priv->mode_config.zpos_prop. We
> need it there so that generic core code (in drm_atomic_plane_set_property)
> can decode it. That way drivers only need to set up&attach it the prop,
> but otherwise can deal with just the decoded values.

Okay.

> Another consideration: Should we reset zpos to something sane in the fbdev
> helpers, like we do for rotation?

Yes and no. fbdev will enable only one (primary) plane per crtc, so zpos 
set to
zero will be properly "normalized" and then interpreted by the driver. 
However
if no fbdev is used and the driver doesn't subclass drm_plane_state, then
drm_atomic_helper_plane_reset() should set it to some sane initial 
values (the
best would be to use initial values passed to 
drm_object_attach_property() on
plane initialization). The only problem is that I didn't find any good 
place to
store the initial zpos value. In case of exynos, drm_plane_state is 
subclassed,
so I can set it in my own exynos_drm_plane_reset() method.

> Thanks, Daniel
>> ...

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
