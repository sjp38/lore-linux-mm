Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id B23C06B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 05:21:55 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so1443935pab.22
        for <linux-mm@kvack.org>; Wed, 14 May 2014 02:21:55 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id zm3si1334386pac.97.2014.05.14.02.21.54
        for <linux-mm@kvack.org>;
        Wed, 14 May 2014 02:21:54 -0700 (PDT)
Date: Wed, 14 May 2014 17:21:48 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 409/499]
 drivers/gpu/drm/vmwgfx/vmwgfx_drv.c:319:54: sparse: Using plain integer as
 NULL pointer
Message-ID: <537335ac.ZObXa1L0TEvThn1M%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_537335ac.Yu8HMBp0TAa7O+2HTikrRVRmkUmi6o0rI5A/QAYJ315BSY6M"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hans Verkuil <hverkuil@xs4all.nl>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

This is a multi-part message in MIME format.

--=_537335ac.Yu8HMBp0TAa7O+2HTikrRVRmkUmi6o0rI5A/QAYJ315BSY6M
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   1055821ba3c83218cbba4481f8349e3326cdaa32
commit: 20fbd93e7b438ae1deea44a4ae632edaab7cee0b [409/499] include/asm-generic/ioctl.h: fix _IOC_TYPECHECK sparse error
reproduce: make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> drivers/gpu/drm/vmwgfx/vmwgfx_drv.c:319:54: sparse: Using plain integer as NULL pointer
--
>> drivers/gpu/drm/drm_ioc32.c:460:17: sparse: cast removes address space of expression
>> drivers/gpu/drm/drm_ioc32.c:460:14: sparse: incorrect type in assignment (different address spaces)
   drivers/gpu/drm/drm_ioc32.c:460:14:    expected struct drm_buf_desc [noderef] <asn:1>*list
   drivers/gpu/drm/drm_ioc32.c:460:14:    got struct drm_buf_desc *<noident>
>> drivers/gpu/drm/drm_ioc32.c:521:17: sparse: cast removes address space of expression
>> drivers/gpu/drm/drm_ioc32.c:521:14: sparse: incorrect type in assignment (different address spaces)
   drivers/gpu/drm/drm_ioc32.c:521:14:    expected struct drm_buf_pub [noderef] <asn:1>*list
   drivers/gpu/drm/drm_ioc32.c:521:14:    got struct drm_buf_pub *<noident>
>> drivers/gpu/drm/drm_ioc32.c:1019:20: sparse: symbol 'drm_compat_ioctls' was not declared. Should it be static?
--
>> drivers/gpu/drm/drm_drv.c:276:37: sparse: incorrect type in argument 1 (different address spaces)
   drivers/gpu/drm/drm_drv.c:276:37:    expected char *buf
   drivers/gpu/drm/drm_drv.c:276:37:    got char [noderef] <asn:1>*name
>> drivers/gpu/drm/drm_drv.c:279:45: sparse: incorrect type in argument 1 (different address spaces)
   drivers/gpu/drm/drm_drv.c:279:45:    expected char *buf
   drivers/gpu/drm/drm_drv.c:279:45:    got char [noderef] <asn:1>*date
>> drivers/gpu/drm/drm_drv.c:282:45: sparse: incorrect type in argument 1 (different address spaces)
   drivers/gpu/drm/drm_drv.c:282:45:    expected char *buf
   drivers/gpu/drm/drm_drv.c:282:45:    got char [noderef] <asn:1>*desc
>> drivers/gpu/drm/drm_drv.c:251:34: sparse: incorrect type in argument 1 (different address spaces)
   drivers/gpu/drm/drm_drv.c:251:34:    expected void [noderef] <asn:1>*to
   drivers/gpu/drm/drm_drv.c:251:34:    got char *buf

Please consider folding the attached diff :-)

vim +319 drivers/gpu/drm/vmwgfx/vmwgfx_drv.c

e2fa3a76 Thomas Hellstrom 2011-10-04  303  
4b9e45e6 Thomas Hellstrom 2013-10-10  304  	/*
4b9e45e6 Thomas Hellstrom 2013-10-10  305  	 * Create the bo as pinned, so that a tryreserve will
4b9e45e6 Thomas Hellstrom 2013-10-10  306  	 * immediately succeed. This is because we're the only
4b9e45e6 Thomas Hellstrom 2013-10-10  307  	 * user of the bo currently.
4b9e45e6 Thomas Hellstrom 2013-10-10  308  	 */
4b9e45e6 Thomas Hellstrom 2013-10-10  309  	ret = ttm_bo_create(&dev_priv->bdev,
4b9e45e6 Thomas Hellstrom 2013-10-10  310  			    PAGE_SIZE,
4b9e45e6 Thomas Hellstrom 2013-10-10  311  			    ttm_bo_type_device,
4b9e45e6 Thomas Hellstrom 2013-10-10  312  			    &vmw_sys_ne_placement,
4b9e45e6 Thomas Hellstrom 2013-10-10  313  			    0, false, NULL,
4b9e45e6 Thomas Hellstrom 2013-10-10  314  			    &bo);
4b9e45e6 Thomas Hellstrom 2013-10-10  315  
e2fa3a76 Thomas Hellstrom 2011-10-04  316  	if (unlikely(ret != 0))
4b9e45e6 Thomas Hellstrom 2013-10-10  317  		return ret;
4b9e45e6 Thomas Hellstrom 2013-10-10  318  
4b9e45e6 Thomas Hellstrom 2013-10-10 @319  	ret = ttm_bo_reserve(bo, false, true, false, 0);
4b9e45e6 Thomas Hellstrom 2013-10-10  320  	BUG_ON(ret != 0);
e2fa3a76 Thomas Hellstrom 2011-10-04  321  
e2fa3a76 Thomas Hellstrom 2011-10-04  322  	ret = ttm_bo_kmap(bo, 0, 1, &map);
e2fa3a76 Thomas Hellstrom 2011-10-04  323  	if (likely(ret == 0)) {
e2fa3a76 Thomas Hellstrom 2011-10-04  324  		result = ttm_kmap_obj_virtual(&map, &dummy);
e2fa3a76 Thomas Hellstrom 2011-10-04  325  		result->totalSize = sizeof(*result);
e2fa3a76 Thomas Hellstrom 2011-10-04  326  		result->state = SVGA3D_QUERYSTATE_PENDING;
e2fa3a76 Thomas Hellstrom 2011-10-04  327  		result->result32 = 0xff;

:::::: The code at line 319 was first introduced by commit
:::::: 4b9e45e68ff9ccd241fa61f9eff1cbddabc05ea1 drm/vmwgfx: Ditch the vmw_dummy_query_bo_prepare function

:::::: TO: Thomas Hellstrom <thellstrom@vmware.com>
:::::: CC: Thomas Hellstrom <thellstrom@vmware.com>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--=_537335ac.Yu8HMBp0TAa7O+2HTikrRVRmkUmi6o0rI5A/QAYJ315BSY6M
Content-Type: text/x-diff;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="make-it-static-20fbd93e7b438ae1deea44a4ae632edaab7cee0b.diff"

From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH mmotm] include/asm-generic/ioctl.h: drm_compat_ioctls[] can be static
TO: Hans Verkuil <hverkuil@xs4all.nl>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: dri-devel@lists.freedesktop.org 
CC: linux-kernel@vger.kernel.org 

CC: Hans Verkuil <hverkuil@xs4all.nl>
CC: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 drm_ioc32.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/drm_ioc32.c b/drivers/gpu/drm/drm_ioc32.c
index 2f4c4343..aa8bbb4 100644
--- a/drivers/gpu/drm/drm_ioc32.c
+++ b/drivers/gpu/drm/drm_ioc32.c
@@ -1016,7 +1016,7 @@ static int compat_drm_wait_vblank(struct file *file, unsigned int cmd,
 	return 0;
 }
 
-drm_ioctl_compat_t *drm_compat_ioctls[] = {
+static drm_ioctl_compat_t *drm_compat_ioctls[] = {
 	[DRM_IOCTL_NR(DRM_IOCTL_VERSION32)] = compat_drm_version,
 	[DRM_IOCTL_NR(DRM_IOCTL_GET_UNIQUE32)] = compat_drm_getunique,
 	[DRM_IOCTL_NR(DRM_IOCTL_GET_MAP32)] = compat_drm_getmap,

--=_537335ac.Yu8HMBp0TAa7O+2HTikrRVRmkUmi6o0rI5A/QAYJ315BSY6M--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
