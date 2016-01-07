Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id A89D8828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 08:59:24 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id f206so98838843wmf.0
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 05:59:24 -0800 (PST)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id i9si139940670wjf.175.2016.01.07.05.59.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jan 2016 05:59:23 -0800 (PST)
Received: by mail-wm0-x22a.google.com with SMTP id f206so124716986wmf.0
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 05:59:23 -0800 (PST)
Date: Thu, 7 Jan 2016 14:59:22 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [PATCH 1/4] drm: add support for generic zpos property
Message-ID: <20160107135922.GO8076@phenom.ffwll.local>
References: <1451998373-13708-1-git-send-email-m.szyprowski@samsung.com>
 <1451998373-13708-2-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1451998373-13708-2-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: intel-gfx@lists.freedesktop.org, Linux MM <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jens Axboe <jens.axboe@oracle.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

On Tue, Jan 05, 2016 at 01:52:50PM +0100, Marek Szyprowski wrote:
> This patch adds support for generic plane's zpos property property with
> well-defined semantics:
> - added zpos properties to drm core and plane state structures
> - added helpers for normalizing zpos properties of given set of planes
> - well defined semantics: planes are sorted by zpos values and then plane
>   id value if zpos equals
> 
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>

lgtm I think. Longer-term we want to think whether we don't want to
extract such extensions into separate files, and push the kerneldoc into
an overview DOC: section in there. Just to keep things more closely
together. Benjamin with drm/sti also needs this, so cc'ing him.

> ---
>  Documentation/DocBook/gpu.tmpl      | 14 ++++++++--
>  drivers/gpu/drm/drm_atomic.c        |  4 +++
>  drivers/gpu/drm/drm_atomic_helper.c | 52 +++++++++++++++++++++++++++++++++++++
>  drivers/gpu/drm/drm_crtc.c          | 13 ++++++++++
>  include/drm/drm_atomic_helper.h     |  2 ++
>  include/drm/drm_crtc.h              | 13 ++++++++++
>  6 files changed, 96 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/DocBook/gpu.tmpl b/Documentation/DocBook/gpu.tmpl
> index 6c6e81a9eaf4..e81acd999891 100644
> --- a/Documentation/DocBook/gpu.tmpl
> +++ b/Documentation/DocBook/gpu.tmpl
> @@ -2004,7 +2004,7 @@ void intel_crt_init(struct drm_device *dev)
>  	<td valign="top" >Description/Restrictions</td>
>  	</tr>
>  	<tr>
> -	<td rowspan="37" valign="top" >DRM</td>
> +	<td rowspan="38" valign="top" >DRM</td>
>  	<td valign="top" >Generic</td>
>  	<td valign="top" >a??rotationa??</td>
>  	<td valign="top" >BITMASK</td>
> @@ -2256,7 +2256,7 @@ void intel_crt_init(struct drm_device *dev)
>  	<td valign="top" >property to suggest an Y offset for a connector</td>
>  	</tr>
>  	<tr>
> -	<td rowspan="3" valign="top" >Optional</td>
> +	<td rowspan="4" valign="top" >Optional</td>
>  	<td valign="top" >a??scaling modea??</td>
>  	<td valign="top" >ENUM</td>
>  	<td valign="top" >{ "None", "Full", "Center", "Full aspect" }</td>
> @@ -2280,6 +2280,16 @@ void intel_crt_init(struct drm_device *dev)
>  	<td valign="top" >TBD</td>
>  	</tr>
>  	<tr>
> +	<td valign="top" > "zpos" </td>
> +	<td valign="top" >RANGE</td>
> +	<td valign="top" >Min=0, Max=255</td>
> +	<td valign="top" >Plane</td>
> +	<td valign="top" >Plane's 'z' position during blending (0 for background, 255 for frontmost).
> +		If two planes assigned to same CRTC have equal zpos values, the plane with higher plane
> +		id is treated as closer to front. Can be IMMUTABLE if driver doesn't support changing
> +		plane's order.</td>
> +	</tr>
> +	<tr>
>  	<td rowspan="20" valign="top" >i915</td>
>  	<td rowspan="2" valign="top" >Generic</td>
>  	<td valign="top" >"Broadcast RGB"</td>
> diff --git a/drivers/gpu/drm/drm_atomic.c b/drivers/gpu/drm/drm_atomic.c
> index 6a21e5c378c1..97bb069cb6a3 100644
> --- a/drivers/gpu/drm/drm_atomic.c
> +++ b/drivers/gpu/drm/drm_atomic.c
> @@ -614,6 +614,8 @@ int drm_atomic_plane_set_property(struct drm_plane *plane,
>  		state->src_h = val;
>  	} else if (property == config->rotation_property) {
>  		state->rotation = val;
> +	} else if (property == config->zpos_property) {
> +		state->zpos = val;
>  	} else if (plane->funcs->atomic_set_property) {
>  		return plane->funcs->atomic_set_property(plane, state,
>  				property, val);
> @@ -670,6 +672,8 @@ drm_atomic_plane_get_property(struct drm_plane *plane,
>  		*val = state->src_h;
>  	} else if (property == config->rotation_property) {
>  		*val = state->rotation;
> +	} else if (property == config->zpos_property) {
> +		*val = state->zpos;
>  	} else if (plane->funcs->atomic_get_property) {
>  		return plane->funcs->atomic_get_property(plane, state, property, val);
>  	} else {
> diff --git a/drivers/gpu/drm/drm_atomic_helper.c b/drivers/gpu/drm/drm_atomic_helper.c
> index 268d37f26960..de3ca33eb696 100644
> --- a/drivers/gpu/drm/drm_atomic_helper.c
> +++ b/drivers/gpu/drm/drm_atomic_helper.c
> @@ -31,6 +31,7 @@
>  #include <drm/drm_crtc_helper.h>
>  #include <drm/drm_atomic_helper.h>
>  #include <linux/fence.h>
> +#include <linux/sort.h>
>  
>  /**
>   * DOC: overview
> @@ -2781,3 +2782,54 @@ void drm_atomic_helper_connector_destroy_state(struct drm_connector *connector,
>  	kfree(state);
>  }
>  EXPORT_SYMBOL(drm_atomic_helper_connector_destroy_state);
> +
> +/**
> + * __drm_atomic_helper_plane_zpos_cmp - compare zpos value of two planes
> + * @a: pointer to first plane
> + * @b: pointer to second plane

Generally we don't do kerneldoc for non-exported functions. If you want
just keep the text itself as a comment, or better move it into the
official interface docs for drm_atomic_helper_normalize_zpos().

> + *
> + * This function is used for comparing two planes while sorting them to assign
> + * a normalized zpos values. Planes are compared first by their zpos values,
> + * then in case they equal, by plane id.
> + */
> +static int __drm_atomic_helper_plane_zpos_cmp(const void *a, const void *b)
> +{
> +	const struct drm_plane *pa = *(struct drm_plane **)a;
> +	const struct drm_plane *pb = *(struct drm_plane **)b;
> +	int zpos_a = 0, zpos_b = 0;
> +
> +	if (pa->state)
> +		zpos_a = pa->state->zpos << 16;
> +	if (pb->state)
> +		zpos_b = pb->state->zpos << 16;
> +
> +	zpos_a += pa->base.id;
> +	zpos_b += pb->base.id;
> +
> +	return zpos_a - zpos_b;
> +}
> +
> +/**
> + * drm_atomic_helper_normalize_zpos - calculate normalized zpos values
> + * @planes: arrays of pointer to planes to consider for normalization
> + * @count: number of planes in the above array
> + *
> + * This function takes arrays of pointers to planes and calculates normalized
> + * zpos value for them taking into account each planes[i]->state->zpos value
> + * and plane's id (if zpos equals). The plane[i]->state->normalized_zpos is
> + * then filled with uniqe values from 0 to count-1.
> + * Note: a side effect of this function is the fact that the planes array will
> + * be modified (sorted). It is up to the called to construct planes array with
> + * all planes that have been assigned to given crtc.
> + */
> +void drm_atomic_helper_normalize_zpos(struct drm_plane *planes[], int count)
> +{
> +	int i;
> +
> +	sort(planes, count, sizeof(struct drm_plane *),
> +	     __drm_atomic_helper_plane_zpos_cmp, NULL);
> +	for (i = 0; i < count; i++)
> +		if (planes[i]->state)
> +			planes[i]->state->normalized_zpos = i;
> +}
> +EXPORT_SYMBOL(drm_atomic_helper_normalize_zpos);
> diff --git a/drivers/gpu/drm/drm_crtc.c b/drivers/gpu/drm/drm_crtc.c
> index 62fa95fa5471..51474ea179f6 100644
> --- a/drivers/gpu/drm/drm_crtc.c
> +++ b/drivers/gpu/drm/drm_crtc.c
> @@ -5879,6 +5879,19 @@ struct drm_property *drm_mode_create_rotation_property(struct drm_device *dev,
>  }
>  EXPORT_SYMBOL(drm_mode_create_rotation_property);
>  

Please add minimal kerneldoc for these two, with the suggestions that
drivers should use drm_atomic_helper_normalize_zpos(). Also, I'd
duplicated the semantic definition here (and explain why immutable
exists) from the gpu.tmpl table.

> +struct drm_property *drm_plane_create_zpos_property(struct drm_device *dev)
> +{
> +	return drm_property_create_range(dev, 0, "zpos", 0, 255);

The zpos property should be stored in dev_priv->mode_config.zpos_prop. We
need it there so that generic core code (in drm_atomic_plane_set_property)
can decode it. That way drivers only need to set up&attach it the prop,
but otherwise can deal with just the decoded values.

Another consideration: Should we reset zpos to something sane in the fbdev
helpers, like we do for rotation?

Thanks, Daniel
> +}
> +EXPORT_SYMBOL(drm_plane_create_zpos_property);
> +
> +struct drm_property *drm_plane_create_zpos_immutable_property(struct drm_device *dev)
> +{
> +	return drm_property_create_range(dev, DRM_MODE_PROP_IMMUTABLE, "zpos",
> +					 0, 255);
> +}
> +EXPORT_SYMBOL(drm_plane_create_zpos_immutable_property);
> +
>  /**
>   * DOC: Tile group
>   *
> diff --git a/include/drm/drm_atomic_helper.h b/include/drm/drm_atomic_helper.h
> index a286cce98720..2a7ade5ad8bd 100644
> --- a/include/drm/drm_atomic_helper.h
> +++ b/include/drm/drm_atomic_helper.h
> @@ -141,6 +141,8 @@ __drm_atomic_helper_connector_destroy_state(struct drm_connector *connector,
>  void drm_atomic_helper_connector_destroy_state(struct drm_connector *connector,
>  					  struct drm_connector_state *state);
>  
> +void drm_atomic_helper_normalize_zpos(struct drm_plane *planes[], int count);
> +
>  /**
>   * drm_atomic_crtc_for_each_plane - iterate over planes currently attached to CRTC
>   * @plane: the loop cursor
> diff --git a/include/drm/drm_crtc.h b/include/drm/drm_crtc.h
> index 3b040b355472..5021aa0237b9 100644
> --- a/include/drm/drm_crtc.h
> +++ b/include/drm/drm_crtc.h
> @@ -1243,6 +1243,9 @@ struct drm_connector {
>   *	plane (in 16.16)
>   * @src_w: width of visible portion of plane (in 16.16)
>   * @src_h: height of visible portion of plane (in 16.16)
> + * @zpos: priority of the given plane on crtc (optional)
> + * @normalized_zpos: normalized value of zpos: uniqe, range from 0 to
> + *	(number of planes - 1) for given crtc
>   * @state: backpointer to global drm_atomic_state
>   */
>  struct drm_plane_state {
> @@ -1263,6 +1266,10 @@ struct drm_plane_state {
>  	/* Plane rotation */
>  	unsigned int rotation;
>  
> +	/* Plane zpos */
> +	unsigned int zpos;
> +	unsigned int normalized_zpos;
> +
>  	struct drm_atomic_state *state;
>  };
>  
> @@ -2083,6 +2090,8 @@ struct drm_mode_config {
>  	struct drm_property *tile_property;
>  	struct drm_property *plane_type_property;
>  	struct drm_property *rotation_property;
> +	struct drm_property *zpos_property;
> +	struct drm_property *zpos_immutable_property;
>  	struct drm_property *prop_src_x;
>  	struct drm_property *prop_src_y;
>  	struct drm_property *prop_src_w;
> @@ -2484,6 +2493,10 @@ extern struct drm_property *drm_mode_create_rotation_property(struct drm_device
>  extern unsigned int drm_rotation_simplify(unsigned int rotation,
>  					  unsigned int supported_rotations);
>  
> +extern struct drm_property *drm_plane_create_zpos_property(struct drm_device *dev);
> +
> +extern struct drm_property *drm_plane_create_zpos_immutable_property(struct drm_device *dev);
> +
>  /* Helpers */
>  
>  static inline struct drm_plane *drm_plane_find(struct drm_device *dev,
> -- 
> 1.9.2
> 

-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
