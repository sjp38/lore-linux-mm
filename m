Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 8514E6B010D
	for <linux-mm@kvack.org>; Wed,  9 May 2012 10:45:54 -0400 (EDT)
Received: by dakp5 with SMTP id p5so541229dak.14
        for <linux-mm@kvack.org>; Wed, 09 May 2012 07:45:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1336544259-17222-3-git-send-email-inki.dae@samsung.com>
References: <1335188594-17454-4-git-send-email-inki.dae@samsung.com>
	<1336544259-17222-1-git-send-email-inki.dae@samsung.com>
	<1336544259-17222-3-git-send-email-inki.dae@samsung.com>
Date: Wed, 9 May 2012 10:45:53 -0400
Message-ID: <CAH3drwZBb=XBYpx=Fv=Xv0hajic51V9RwzY_-CpjKDuxgAj9Qg@mail.gmail.com>
Subject: Re: [PATCH 2/2 v3] drm/exynos: added userptr feature.
From: Jerome Glisse <j.glisse@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Inki Dae <inki.dae@samsung.com>
Cc: airlied@linux.ie, dri-devel@lists.freedesktop.org, kyungmin.park@samsung.com, sw0312.kim@samsung.com, linux-mm@kvack.org

On Wed, May 9, 2012 at 2:17 AM, Inki Dae <inki.dae@samsung.com> wrote:
> this feature is used to import user space region allocated by malloc() or
> mmaped into a gem. and to guarantee the pages to user space not to be
> swapped out, the VMAs within the user space would be locked and then unlo=
cked
> when the pages are released.
>
> but this lock might result in significant degradation of system performan=
ce
> because the pages couldn't be swapped out so we limit user-desired userpt=
r
> size to pre-defined.
>
> Signed-off-by: Inki Dae <inki.dae@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>


Again i would like feedback from mm people (adding cc). I am not sure
locking the vma is the right anwser as i said in my previous mail,
userspace can munlock it in your back, maybe VM_RESERVED is better.
Anyway even not considering that you don't check at all that process
don't go over the limit of locked page see mm/mlock.c RLIMIT_MEMLOCK
for how it's done. Also you mlock complete vma but the userptr you get
might be inside say 16M vma and you only care about 1M of userptr, if
you mark the whole vma as locked than anytime a new page is fault in
the vma else where than in the buffer you are interested then it got
allocated for ever until the gem buffer is destroy, i am not sure of
what happen to the vma on next malloc if it grows or not (i would
think it won't grow at it would have different flags than new
anonymous memory).

The whole business of directly using malloced memory for gpu is fishy
and i would really like to get it right rather than relying on never
hitting strange things like page migration, vma merging, or worse
things like over locking pages and stealing memory.

Cheers,
Jerome


> ---
> =A0drivers/gpu/drm/exynos/exynos_drm_drv.c | =A0 =A02 +
> =A0drivers/gpu/drm/exynos/exynos_drm_gem.c | =A0334 +++++++++++++++++++++=
++++++++++
> =A0drivers/gpu/drm/exynos/exynos_drm_gem.h | =A0 17 ++-
> =A0include/drm/exynos_drm.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 26 +++-
> =A04 files changed, 376 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/gpu/drm/exynos/exynos_drm_drv.c b/drivers/gpu/drm/ex=
ynos/exynos_drm_drv.c
> index 1e68ec2..e8ae3f1 100644
> --- a/drivers/gpu/drm/exynos/exynos_drm_drv.c
> +++ b/drivers/gpu/drm/exynos/exynos_drm_drv.c
> @@ -220,6 +220,8 @@ static struct drm_ioctl_desc exynos_ioctls[] =3D {
> =A0 =A0 =A0 =A0DRM_IOCTL_DEF_DRV(EXYNOS_GEM_MAP_OFFSET,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0exynos_drm_gem_map_offset_=
ioctl, DRM_UNLOCKED |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0DRM_AUTH),
> + =A0 =A0 =A0 DRM_IOCTL_DEF_DRV(EXYNOS_GEM_USERPTR,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 exynos_drm_gem_userptr_ioct=
l, DRM_UNLOCKED),
> =A0 =A0 =A0 =A0DRM_IOCTL_DEF_DRV(EXYNOS_GEM_MMAP,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0exynos_drm_gem_mmap_ioctl,=
 DRM_UNLOCKED | DRM_AUTH),
> =A0 =A0 =A0 =A0DRM_IOCTL_DEF_DRV(EXYNOS_GEM_GET,
> diff --git a/drivers/gpu/drm/exynos/exynos_drm_gem.c b/drivers/gpu/drm/ex=
ynos/exynos_drm_gem.c
> index e6abb66..ccc6e3d 100644
> --- a/drivers/gpu/drm/exynos/exynos_drm_gem.c
> +++ b/drivers/gpu/drm/exynos/exynos_drm_gem.c
> @@ -68,6 +68,83 @@ static int check_gem_flags(unsigned int flags)
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> +static struct vm_area_struct *get_vma(struct vm_area_struct *vma)
> +{
> + =A0 =A0 =A0 struct vm_area_struct *vma_copy;
> +
> + =A0 =A0 =A0 vma_copy =3D kmalloc(sizeof(*vma_copy), GFP_KERNEL);
> + =A0 =A0 =A0 if (!vma_copy)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> +
> + =A0 =A0 =A0 if (vma->vm_ops && vma->vm_ops->open)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vma->vm_ops->open(vma);
> +
> + =A0 =A0 =A0 if (vma->vm_file)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 get_file(vma->vm_file);
> +
> + =A0 =A0 =A0 memcpy(vma_copy, vma, sizeof(*vma));
> +
> + =A0 =A0 =A0 vma_copy->vm_mm =3D NULL;
> + =A0 =A0 =A0 vma_copy->vm_next =3D NULL;
> + =A0 =A0 =A0 vma_copy->vm_prev =3D NULL;
> +
> + =A0 =A0 =A0 return vma_copy;
> +}
> +
> +
> +static void put_vma(struct vm_area_struct *vma)
> +{
> + =A0 =A0 =A0 if (!vma)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 if (vma->vm_ops && vma->vm_ops->close)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vma->vm_ops->close(vma);
> +
> + =A0 =A0 =A0 if (vma->vm_file)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fput(vma->vm_file);
> +
> + =A0 =A0 =A0 kfree(vma);
> +}
> +
> +/*
> + * lock_userptr_vma - lock VMAs within user address space
> + *
> + * this function locks vma within user address space to avoid pages
> + * to the userspace from being swapped out.
> + * if this vma isn't locked, the pages to the userspace could be swapped=
 out
> + * so unprivileged user might access different pages and dma of any devi=
ce
> + * could access physical memory region not intended once swap-in.
> + */
> +static int lock_userptr_vma(struct exynos_drm_gem_buf *buf, unsigned int=
 lock)
> +{
> + =A0 =A0 =A0 struct vm_area_struct *vma;
> + =A0 =A0 =A0 unsigned long start, end;
> +
> + =A0 =A0 =A0 start =3D buf->userptr;
> + =A0 =A0 =A0 end =3D buf->userptr + buf->size - 1;
> +
> + =A0 =A0 =A0 down_write(&current->mm->mmap_sem);
> +
> + =A0 =A0 =A0 do {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vma =3D find_vma(current->mm, start);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!vma) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 up_write(&current->mm->mmap=
_sem);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EFAULT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (lock)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vma->vm_flags |=3D VM_LOCKE=
D;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vma->vm_flags &=3D ~VM_LOCK=
ED;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 start =3D vma->vm_end + 1;
> + =A0 =A0 =A0 } while (vma->vm_end < end);
> +
> + =A0 =A0 =A0 up_write(&current->mm->mmap_sem);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> =A0static void update_vm_cache_attr(struct exynos_drm_gem_obj *obj,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0struct vm_area_struct *vma)
> =A0{
> @@ -256,6 +333,44 @@ static void exynos_drm_gem_put_pages(struct drm_gem_=
object *obj)
> =A0 =A0 =A0 =A0/* add some codes for UNCACHED type here. TODO */
> =A0}
>
> +static void exynos_drm_put_userptr(struct drm_gem_object *obj)
> +{
> + =A0 =A0 =A0 struct exynos_drm_gem_obj *exynos_gem_obj;
> + =A0 =A0 =A0 struct exynos_drm_gem_buf *buf;
> + =A0 =A0 =A0 struct vm_area_struct *vma;
> + =A0 =A0 =A0 int npages;
> +
> + =A0 =A0 =A0 exynos_gem_obj =3D to_exynos_gem_obj(obj);
> + =A0 =A0 =A0 buf =3D exynos_gem_obj->buffer;
> + =A0 =A0 =A0 vma =3D exynos_gem_obj->vma;
> +
> + =A0 =A0 =A0 if (vma && (vma->vm_flags & VM_PFNMAP) && (vma->vm_pgoff)) =
{
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_vma(exynos_gem_obj->vma);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 npages =3D buf->size >> PAGE_SHIFT;
> +
> + =A0 =A0 =A0 if (exynos_gem_obj->flags & EXYNOS_BO_USERPTR && !buf->pfnm=
ap)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_userptr_vma(buf, 0);
> +
> + =A0 =A0 =A0 npages--;
> + =A0 =A0 =A0 while (npages >=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (buf->write)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_page_dirty_lock(buf->pa=
ges[npages]);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_page(buf->pages[npages]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 npages--;
> + =A0 =A0 =A0 }
> +
> +out:
> + =A0 =A0 =A0 kfree(buf->pages);
> + =A0 =A0 =A0 buf->pages =3D NULL;
> +
> + =A0 =A0 =A0 kfree(buf->sgt);
> + =A0 =A0 =A0 buf->sgt =3D NULL;
> +}
> +
> =A0static int exynos_drm_gem_handle_create(struct drm_gem_object *obj,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0struct drm_file *file_priv,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0unsigned int *handle)
> @@ -295,6 +410,8 @@ void exynos_drm_gem_destroy(struct exynos_drm_gem_obj=
 *exynos_gem_obj)
>
> =A0 =A0 =A0 =A0if (exynos_gem_obj->flags & EXYNOS_BO_NONCONTIG)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0exynos_drm_gem_put_pages(obj);
> + =A0 =A0 =A0 else if (exynos_gem_obj->flags & EXYNOS_BO_USERPTR)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 exynos_drm_put_userptr(obj);
> =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0exynos_drm_free_buf(obj->dev, exynos_gem_o=
bj->flags, buf);
>
> @@ -606,6 +723,223 @@ int exynos_drm_gem_mmap_ioctl(struct drm_device *de=
v, void *data,
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> +static int exynos_drm_get_userptr(struct drm_device *dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct exyn=
os_drm_gem_obj *obj,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned lo=
ng userptr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned in=
t write)
> +{
> + =A0 =A0 =A0 unsigned int get_npages;
> + =A0 =A0 =A0 unsigned long npages =3D 0;
> + =A0 =A0 =A0 struct vm_area_struct *vma;
> + =A0 =A0 =A0 struct exynos_drm_gem_buf *buf =3D obj->buffer;
> + =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 down_read(&current->mm->mmap_sem);
> + =A0 =A0 =A0 vma =3D find_vma(current->mm, userptr);
> +
> + =A0 =A0 =A0 /* the memory region mmaped with VM_PFNMAP. */
> + =A0 =A0 =A0 if (vma && (vma->vm_flags & VM_PFNMAP) && (vma->vm_pgoff)) =
{
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long this_pfn, prev_pfn, pa;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long start, end, offset;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct scatterlist *sgl;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 start =3D userptr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 offset =3D userptr & ~PAGE_MASK;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 end =3D start + buf->size;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sgl =3D buf->sgt->sgl;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (prev_pfn =3D 0; start < end; start +=
=3D PAGE_SIZE) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D follow_pfn(vma, sta=
rt, &this_pfn);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (prev_pfn =3D=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pa =3D this=
_pfn << PAGE_SHIFT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 buf->dma_ad=
dr =3D pa + offset;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else if (this_pfn !=3D pr=
ev_pfn + 1) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -EI=
NVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sg_dma_address(sgl) =3D (pa=
 + offset);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sg_dma_len(sgl) =3D PAGE_SI=
ZE;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 prev_pfn =3D this_pfn;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pa +=3D PAGE_SIZE;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 npages++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sgl =3D sg_next(sgl);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 obj->vma =3D get_vma(vma);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!obj->vma) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -ENOMEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 up_read(&current->mm->mmap_sem);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 buf->pfnmap =3D true;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return npages;
> +err:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 buf->dma_addr =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 up_read(&current->mm->mmap_sem);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 up_read(&current->mm->mmap_sem);
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* lock the vma within userptr to avoid userspace buffer
> + =A0 =A0 =A0 =A0* from being swapped out.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 ret =3D lock_userptr_vma(buf, 1);
> + =A0 =A0 =A0 if (ret < 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 DRM_ERROR("failed to lock vma for userptr.\=
n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_userptr_vma(buf, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 buf->write =3D write;
> + =A0 =A0 =A0 npages =3D buf->size >> PAGE_SHIFT;
> +
> + =A0 =A0 =A0 down_read(&current->mm->mmap_sem);
> + =A0 =A0 =A0 get_npages =3D get_user_pages(current, current->mm, userptr=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 npages, write, 1, buf->pages, NULL);
> + =A0 =A0 =A0 up_read(&current->mm->mmap_sem);
> + =A0 =A0 =A0 if (get_npages !=3D npages)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 DRM_ERROR("failed to get user_pages.\n");
> +
> + =A0 =A0 =A0 buf->userptr =3D userptr;
> + =A0 =A0 =A0 buf->pfnmap =3D false;
> +
> + =A0 =A0 =A0 return get_npages;
> +}
> +
> +int exynos_drm_gem_userptr_ioctl(struct drm_device *dev, void *data,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 struct drm_file *file_priv)
> +{
> + =A0 =A0 =A0 struct exynos_drm_private *priv =3D dev->dev_private;
> + =A0 =A0 =A0 struct exynos_drm_gem_obj *exynos_gem_obj;
> + =A0 =A0 =A0 struct drm_exynos_gem_userptr *args =3D data;
> + =A0 =A0 =A0 struct exynos_drm_gem_buf *buf;
> + =A0 =A0 =A0 struct scatterlist *sgl;
> + =A0 =A0 =A0 unsigned long size, userptr;
> + =A0 =A0 =A0 unsigned int npages;
> + =A0 =A0 =A0 int ret, get_npages;
> +
> + =A0 =A0 =A0 DRM_DEBUG_KMS("%s\n", __FILE__);
> +
> + =A0 =A0 =A0 if (!args->size) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 DRM_ERROR("invalid size.\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 ret =3D check_gem_flags(args->flags);
> + =A0 =A0 =A0 if (ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> +
> + =A0 =A0 =A0 size =3D roundup_gem_size(args->size, EXYNOS_BO_USERPTR);
> +
> + =A0 =A0 =A0 if (size > priv->userptr_limit) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 DRM_ERROR("excessed maximum size of userptr=
.\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 userptr =3D args->userptr;
> +
> + =A0 =A0 =A0 buf =3D exynos_drm_init_buf(dev, size);
> + =A0 =A0 =A0 if (!buf)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> +
> + =A0 =A0 =A0 exynos_gem_obj =3D exynos_drm_gem_init(dev, size);
> + =A0 =A0 =A0 if (!exynos_gem_obj) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -ENOMEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_free_buffer;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 buf->sgt =3D kzalloc(sizeof(struct sg_table), GFP_KERNEL);
> + =A0 =A0 =A0 if (!buf->sgt) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 DRM_ERROR("failed to allocate buf->sgt.\n")=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -ENOMEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_release_gem;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 npages =3D size >> PAGE_SHIFT;
> +
> + =A0 =A0 =A0 ret =3D sg_alloc_table(buf->sgt, npages, GFP_KERNEL);
> + =A0 =A0 =A0 if (ret < 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 DRM_ERROR("failed to initailize sg table.\n=
");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_free_sgt;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 buf->pages =3D kzalloc(npages * sizeof(struct page *), GFP_=
KERNEL);
> + =A0 =A0 =A0 if (!buf->pages) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 DRM_ERROR("failed to allocate buf->pages\n"=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -ENOMEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_free_table;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 exynos_gem_obj->buffer =3D buf;
> +
> + =A0 =A0 =A0 get_npages =3D exynos_drm_get_userptr(dev, exynos_gem_obj, =
userptr, 1);
> + =A0 =A0 =A0 if (get_npages !=3D npages) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 DRM_ERROR("failed to get user_pages.\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D get_npages;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_release_userptr;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 ret =3D exynos_drm_gem_handle_create(&exynos_gem_obj->base,=
 file_priv,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 &args->handle);
> + =A0 =A0 =A0 if (ret < 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 DRM_ERROR("failed to create gem handle.\n")=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_release_userptr;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 sgl =3D buf->sgt->sgl;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* if buf->pfnmap is true then update sgl of sgt with pag=
es but
> + =A0 =A0 =A0 =A0* if buf->pfnmap is false then it means the sgl was upda=
ted already
> + =A0 =A0 =A0 =A0* so it doesn't need to update the sgl.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (!buf->pfnmap) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int i =3D 0;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* set all pages to sg list. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (i < npages) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sg_set_page(sgl, buf->pages=
[i], PAGE_SIZE, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sg_dma_address(sgl) =3D pag=
e_to_phys(buf->pages[i]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 i++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sgl =3D sg_next(sgl);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* always use EXYNOS_BO_USERPTR as memory type for userptr.=
 */
> + =A0 =A0 =A0 exynos_gem_obj->flags |=3D EXYNOS_BO_USERPTR;
> +
> + =A0 =A0 =A0 return 0;
> +
> +err_release_userptr:
> + =A0 =A0 =A0 get_npages--;
> + =A0 =A0 =A0 while (get_npages >=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_page(buf->pages[get_npages--]);
> + =A0 =A0 =A0 kfree(buf->pages);
> + =A0 =A0 =A0 buf->pages =3D NULL;
> +err_free_table:
> + =A0 =A0 =A0 sg_free_table(buf->sgt);
> +err_free_sgt:
> + =A0 =A0 =A0 kfree(buf->sgt);
> + =A0 =A0 =A0 buf->sgt =3D NULL;
> +err_release_gem:
> + =A0 =A0 =A0 drm_gem_object_release(&exynos_gem_obj->base);
> + =A0 =A0 =A0 kfree(exynos_gem_obj);
> + =A0 =A0 =A0 exynos_gem_obj =3D NULL;
> +err_free_buffer:
> + =A0 =A0 =A0 exynos_drm_free_buf(dev, 0, buf);
> + =A0 =A0 =A0 return ret;
> +}
> +
> =A0int exynos_drm_gem_get_ioctl(struct drm_device *dev, void *data,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0struct drm_file *file_priv)
> =A0{ =A0 =A0 =A0struct exynos_drm_gem_obj *exynos_gem_obj;
> diff --git a/drivers/gpu/drm/exynos/exynos_drm_gem.h b/drivers/gpu/drm/ex=
ynos/exynos_drm_gem.h
> index 3334c9f..72bd993 100644
> --- a/drivers/gpu/drm/exynos/exynos_drm_gem.h
> +++ b/drivers/gpu/drm/exynos/exynos_drm_gem.h
> @@ -29,27 +29,35 @@
> =A0#define to_exynos_gem_obj(x) =A0 container_of(x,\
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct exynos_drm_gem_obj,=
 base)
>
> -#define IS_NONCONTIG_BUFFER(f) =A0 =A0 =A0 =A0 (f & EXYNOS_BO_NONCONTIG)
> +#define IS_NONCONTIG_BUFFER(f) ((f & EXYNOS_BO_NONCONTIG) ||\
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 (f & EXYNOS_BO_USERPTR))
>
> =A0/*
> =A0* exynos drm gem buffer structure.
> =A0*
> =A0* @kvaddr: kernel virtual address to allocated memory region.
> + * @userptr: user space address.
> =A0* @dma_addr: bus address(accessed by dma) to allocated memory region.
> =A0* =A0 =A0 - this address could be physical address without IOMMU and
> =A0* =A0 =A0 device address with IOMMU.
> + * @write: whether pages will be written to by the caller.
> =A0* @sgt: sg table to transfer page data.
> =A0* @pages: contain all pages to allocated memory region.
> =A0* @page_size: could be 4K, 64K or 1MB.
> =A0* @size: size of allocated memory region.
> + * @pfnmap: indicate whether memory region from userptr is mmaped with
> + * =A0 =A0 VM_PFNMAP or not.
> =A0*/
> =A0struct exynos_drm_gem_buf {
> =A0 =A0 =A0 =A0void __iomem =A0 =A0 =A0 =A0 =A0 =A0*kvaddr;
> + =A0 =A0 =A0 unsigned long =A0 =A0 =A0 =A0 =A0 userptr;
> =A0 =A0 =A0 =A0dma_addr_t =A0 =A0 =A0 =A0 =A0 =A0 =A0dma_addr;
> + =A0 =A0 =A0 unsigned int =A0 =A0 =A0 =A0 =A0 =A0write;
> =A0 =A0 =A0 =A0struct sg_table =A0 =A0 =A0 =A0 *sgt;
> =A0 =A0 =A0 =A0struct page =A0 =A0 =A0 =A0 =A0 =A0 **pages;
> =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 page_size;
> =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 size;
> + =A0 =A0 =A0 bool =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pfnmap;
> =A0};
>
> =A0/*
> @@ -64,6 +72,8 @@ struct exynos_drm_gem_buf {
> =A0* =A0 =A0 continuous memory region allocated by user request
> =A0* =A0 =A0 or at framebuffer creation.
> =A0* @size: total memory size to physically non-continuous memory region.
> + * @vma: a pointer to the vma to user address space and used to release
> + * =A0 =A0 the pages to user space.
> =A0* @flags: indicate memory type to allocated buffer and cache attruibut=
e.
> =A0*
> =A0* P.S. this object would be transfered to user as kms_bo.handle so
> @@ -73,6 +83,7 @@ struct exynos_drm_gem_obj {
> =A0 =A0 =A0 =A0struct drm_gem_object =A0 =A0 =A0 =A0 =A0 base;
> =A0 =A0 =A0 =A0struct exynos_drm_gem_buf =A0 =A0 =A0 *buffer;
> =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size;
> + =A0 =A0 =A0 struct vm_area_struct =A0 =A0 =A0 =A0 =A0 *vma;
> =A0 =A0 =A0 =A0unsigned int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0flags;
> =A0};
>
> @@ -130,6 +141,10 @@ int exynos_drm_gem_map_offset_ioctl(struct drm_devic=
e *dev, void *data,
> =A0int exynos_drm_gem_mmap_ioctl(struct drm_device *dev, void *data,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct drm_fil=
e *file_priv);
>
> +/* map user space allocated by malloc to pages. */
> +int exynos_drm_gem_userptr_ioctl(struct drm_device *dev, void *data,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 struct drm_file *file_priv);
> +
> =A0/* get buffer information to memory region allocated by gem. */
> =A0int exynos_drm_gem_get_ioctl(struct drm_device *dev, void *data,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0struct drm_file *file_priv);
> diff --git a/include/drm/exynos_drm.h b/include/drm/exynos_drm.h
> index 52465dc..33fa1e2 100644
> --- a/include/drm/exynos_drm.h
> +++ b/include/drm/exynos_drm.h
> @@ -77,6 +77,23 @@ struct drm_exynos_gem_mmap {
> =A0};
>
> =A0/**
> + * User-requested user space importing structure
> + *
> + * @userptr: user space address allocated by malloc.
> + * @size: size to the buffer allocated by malloc.
> + * @flags: indicate user-desired cache attribute to map the allocated bu=
ffer
> + * =A0 =A0 to kernel space.
> + * @handle: a returned handle to created gem object.
> + * =A0 =A0 - this handle will be set by gem module of kernel side.
> + */
> +struct drm_exynos_gem_userptr {
> + =A0 =A0 =A0 uint64_t userptr;
> + =A0 =A0 =A0 uint64_t size;
> + =A0 =A0 =A0 unsigned int flags;
> + =A0 =A0 =A0 unsigned int handle;
> +};
> +
> +/**
> =A0* A structure to gem information.
> =A0*
> =A0* @handle: a handle to gem object created.
> @@ -135,8 +152,10 @@ enum e_drm_exynos_gem_mem_type {
> =A0 =A0 =A0 =A0EXYNOS_BO_CACHABLE =A0 =A0 =A0=3D 1 << 1,
> =A0 =A0 =A0 =A0/* write-combine mapping. */
> =A0 =A0 =A0 =A0EXYNOS_BO_WC =A0 =A0 =A0 =A0 =A0 =A0=3D 1 << 2,
> + =A0 =A0 =A0 /* user space memory allocated by malloc. */
> + =A0 =A0 =A0 EXYNOS_BO_USERPTR =A0 =A0 =A0 =3D 1 << 3,
> =A0 =A0 =A0 =A0EXYNOS_BO_MASK =A0 =A0 =A0 =A0 =A0=3D EXYNOS_BO_NONCONTIG =
| EXYNOS_BO_CACHABLE |
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 EXYNOS_BO_WC
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 EXYNOS_BO_WC | EXYNOS_BO_USERPTR
> =A0};
>
> =A0struct drm_exynos_g2d_get_ver {
> @@ -173,7 +192,7 @@ struct drm_exynos_g2d_exec {
> =A0#define DRM_EXYNOS_GEM_CREATE =A0 =A0 =A0 =A0 =A00x00
> =A0#define DRM_EXYNOS_GEM_MAP_OFFSET =A0 =A0 =A00x01
> =A0#define DRM_EXYNOS_GEM_MMAP =A0 =A0 =A0 =A0 =A0 =A00x02
> -/* Reserved 0x03 ~ 0x05 for exynos specific gem ioctl */
> +#define DRM_EXYNOS_GEM_USERPTR =A0 =A0 =A0 =A0 0x03
> =A0#define DRM_EXYNOS_GEM_GET =A0 =A0 =A0 =A0 =A0 =A0 0x04
> =A0#define DRM_EXYNOS_USER_LIMIT =A0 =A0 =A0 =A0 =A00x05
> =A0#define DRM_EXYNOS_PLANE_SET_ZPOS =A0 =A0 =A00x06
> @@ -193,6 +212,9 @@ struct drm_exynos_g2d_exec {
> =A0#define DRM_IOCTL_EXYNOS_GEM_MMAP =A0 =A0 =A0DRM_IOWR(DRM_COMMAND_BASE=
 + \
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0DRM_EXYNOS_GEM_MMAP, struct drm_exynos_gem=
_mmap)
>
> +#define DRM_IOCTL_EXYNOS_GEM_USERPTR =A0 DRM_IOWR(DRM_COMMAND_BASE + \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 DRM_EXYNOS_GEM_USERPTR, struct drm_exynos_g=
em_userptr)
> +
> =A0#define DRM_IOCTL_EXYNOS_GEM_GET =A0 =A0 =A0 DRM_IOWR(DRM_COMMAND_BASE=
 + \
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0DRM_EXYNOS_GEM_GET, =A0 =A0 struct drm_exy=
nos_gem_info)
>
> --
> 1.7.4.1
>
> _______________________________________________
> dri-devel mailing list
> dri-devel@lists.freedesktop.org
> http://lists.freedesktop.org/mailman/listinfo/dri-devel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
