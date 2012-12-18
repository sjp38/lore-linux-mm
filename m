Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 87D346B005D
	for <linux-mm@kvack.org>; Tue, 18 Dec 2012 17:57:11 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id rp2so767370pbb.1
        for <linux-mm@kvack.org>; Tue, 18 Dec 2012 14:57:10 -0800 (PST)
Date: Tue, 18 Dec 2012 14:53:30 -0800
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [RFC 3/3] virtio-balloon: add auto-ballooning support
Message-ID: <20121218225330.GA28297@lizard.mcd00620.sjc.wayport.net>
References: <1355861815-2607-1-git-send-email-lcapitulino@redhat.com>
 <1355861815-2607-4-git-send-email-lcapitulino@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1355861815-2607-4-git-send-email-lcapitulino@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: qemu-devel@nongnu.org, riel@redhat.com, aquini@redhat.com, mst@redhat.com, amit.shah@redhat.com, agl@us.ibm.com, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello Luiz,

On Tue, Dec 18, 2012 at 06:16:55PM -0200, Luiz Capitulino wrote:
> The auto-ballooning feature automatically performs balloon inflate
> or deflate based on host and guest memory pressure. This can help to
> avoid swapping or worse in both, host and guest.
> 
> Auto-ballooning has a host and a guest part. The host performs
> automatic inflate by requesting the guest to inflate its balloon
> when the host is facing memory pressure. The guest performs
> automatic deflate when it's facing memory pressure itself. It's
> expected that auto-inflate and auto-deflate will balance each
> other over time.
> 
> This commit implements the host side of auto-ballooning.
> 
> To be notified of host memory pressure, this commit makes use of this
> kernel API proposal being discussed upstream:
> 
>  http://marc.info/?l=linux-mm&m=135513372205134&w=2

Wow, you're fast! And I'm glad that it works for you, so we have two
full-featured mempressure cgroup users already.

Even though it is a qemu patch, I think we should Cc linux-mm folks on it,
just to let them know the great news.

Thanks!

> Three new properties are added to the virtio-balloon device to activate
> auto-ballooning:
> 
>   o auto-balloon-mempressure-path: this is the path for the kernel's
>     mempressure cgroup notification dir, which must be already mounted
> 	(see link above for details on this)
> 
>   o auto-balloon-level: the memory pressure level to trigger auto-balloon.
>     Valid values are:
> 
> 		- low: the kernel is reclaiming memory for new allocations
> 		- medium: some swapping activity has already started
> 		- oom: the kernel will start playing russian roulette real soon
> 
>   o auto-balloon-granularity: percentage of current guest memory by which
>     the balloon should be inflated. For example, a value of 1 corresponds
> 	to 1% which means that a guest with 1G of memory will get its balloon
> 	inflated to 10485K.
> 
> To test this, you need a kernel with the mempressure API patch applied and
> the guest side of auto-ballooning.
> 
> Then the feature can be enabled like:
> 
>  qemu [...] \
>    -balloon virtio,auto-balloon-mempressure-path=/sys/fs/cgroup/mempressure/,auto-balloon-level=low,auto-balloon-granularity=1
> 
> FIXMEs:
> 
>    o rate-limit the event? Can receive several in a row
>    o add auto-balloon-maximum to limit the inflate?
>    o this shouldn't override balloon changes done by the user manually
> 
> Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
> ---
>  hw/virtio-balloon.c | 156 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  hw/virtio-balloon.h |   4 ++
>  hw/virtio-pci.c     |   5 ++
>  3 files changed, 165 insertions(+)
> 
> diff --git a/hw/virtio-balloon.c b/hw/virtio-balloon.c
> index 97d49b1..40a97e7 100644
> --- a/hw/virtio-balloon.c
> +++ b/hw/virtio-balloon.c
> @@ -37,6 +37,13 @@ typedef struct VirtIOBalloon
>      VirtQueueElement stats_vq_elem;
>      size_t stats_vq_offset;
>      DeviceState *qdev;
> +
> +    /* auto-balloon */
> +    bool auto_balloon_enabled;
> +    int cfd;
> +    int lfd;
> +    float granularity;
> +    EventNotifier mempressure_ev;
>  } VirtIOBalloon;
>  
>  static VirtIOBalloon *to_virtio_balloon(VirtIODevice *vdev)
> @@ -157,7 +164,14 @@ static void virtio_balloon_set_config(VirtIODevice *vdev,
>  
>  static uint32_t virtio_balloon_get_features(VirtIODevice *vdev, uint32_t f)
>  {
> +    VirtIOBalloon *s = to_virtio_balloon(vdev);
> +
>      f |= (1 << VIRTIO_BALLOON_F_STATS_VQ);
> +
> +    if (s->auto_balloon_enabled) {
> +        f |= (1 << VIRTIO_BALLOON_F_AUTO_BALLOON);
> +    }
> +
>      return f;
>  }
>  
> @@ -166,6 +180,11 @@ static ram_addr_t guest_get_actual_ram(const VirtIOBalloon *s)
>      return ram_size - ((uint64_t) s->actual << VIRTIO_BALLOON_PFN_SHIFT);
>  }
>  
> +static bool guest_supports_auto_balloon(const VirtIOBalloon *s)
> +{
> +    return s->vdev.guest_features & (1 << VIRTIO_BALLOON_F_AUTO_BALLOON);
> +}
> +
>  static void virtio_balloon_stat(void *opaque, BalloonInfo *info)
>  {
>      VirtIOBalloon *dev = opaque;
> @@ -235,6 +254,133 @@ static int virtio_balloon_load(QEMUFile *f, void *opaque, int version_id)
>      return 0;
>  }
>  
> +static int open_sysfile(const char *path, const char *file, mode_t mode)
> +{
> +    char *p;
> +    int fd;
> +
> +    p = g_strjoin("/", path, file, NULL);
> +    fd = qemu_open(p, mode);
> +    if (fd < 0) {
> +        error_report("balloon: can't open '%s': %s", p, strerror(errno));
> +    }
> +
> +    g_free(p);
> +    return fd;
> +}
> +
> +static int balloon_ack_event(EventNotifier *ev)
> +{
> +    uint64_t res;
> +    int ret, fd;
> +
> +    fd = event_notifier_get_fd(ev);
> +
> +    do {
> +        ret = read(fd, &res, sizeof(res));
> +    } while (ret == -1 && errno == EINTR);
> +
> +    return ret;
> +}
> +
> +static void host_mempressure_cleanup(VirtIOBalloon *s);
> +
> +static void host_mempressure_cb(EventNotifier *ev)
> +{
> +    VirtIOBalloon *s = container_of(ev, VirtIOBalloon, mempressure_ev);
> +    ram_addr_t target;
> +    int ret;
> +
> +    ret = balloon_ack_event(&s->mempressure_ev);
> +    if (ret < 0) {
> +        fprintf(stderr, "balloon: failed to ack event: %s\n", strerror(errno));
> +        return;
> +    }
> +
> +    if (!guest_supports_auto_balloon(s)) {
> +        fprintf(stderr,
> +          "balloon: oops guest doesn't support auto-ballooning, disabling..\n");
> +        host_mempressure_cleanup(s);
> +        return;
> +    }
> +
> +    target = guest_get_actual_ram(s) -
> +             (guest_get_actual_ram(s) * s->granularity);
> +    virtio_balloon_to_target(s, target);
> +}
> +
> +static int host_mempressure_init(VirtIOBalloon *s,
> +                                 const virtio_balloon_conf *conf)
> +{
> +    char *line;
> +    int ret, fd;
> +
> +    if (!conf->path || !conf->level) {
> +        error_report("balloon: mempressure path or level missing");
> +        return -1;
> +    }
> +
> +    if (conf->granularity > 100) {
> +        error_report("balloon: invalid granularity value (should be 0..100)");
> +        return -1;
> +    }
> +
> +    s->lfd = open_sysfile(conf->path, "mempressure.level", O_RDONLY);
> +    if (s->lfd < 0) {
> +        return -1;
> +    }
> +
> +    s->cfd = open_sysfile(conf->path, "cgroup.event_control", O_WRONLY);
> +    if (s->cfd < 0) {
> +        close(s->lfd);
> +        return -1;
> +    }
> +
> +    ret = event_notifier_init(&s->mempressure_ev, false);
> +    if (ret < 0) {
> +        error_report("failed to create notifier: %s", strerror(-ret));
> +        goto out_err;
> +    }
> +
> +    fd = event_notifier_get_fd(&s->mempressure_ev);
> +    line = g_strdup_printf("%d %d %s", fd, s->lfd, conf->level);
> +
> +    do {
> +        ret = write(s->cfd, line, strlen(line));
> +    } while (ret < 0 && errno == EINTR);
> +
> +    if (ret < 0) {
> +        error_report("balloon: write failed: %s", strerror(errno));
> +        g_free(line);
> +        goto out_ev;
> +    }
> +
> +    g_free(line);
> +
> +    s->auto_balloon_enabled = true;
> +    s->granularity = conf->granularity / 100.0;
> +    event_notifier_set_handler(&s->mempressure_ev, host_mempressure_cb);
> +
> +    return 0;
> +
> +out_ev:
> +    event_notifier_cleanup(&s->mempressure_ev);
> +out_err:
> +    close(s->lfd);
> +    close(s->cfd);
> +    return -1;
> +}
> +
> +static void host_mempressure_cleanup(VirtIOBalloon *s)
> +{
> +    if (s->auto_balloon_enabled) {
> +        close(s->lfd);
> +        close(s->cfd);
> +        event_notifier_cleanup(&s->mempressure_ev);
> +        s->auto_balloon_enabled = false;
> +    }
> +}
> +
>  VirtIODevice *virtio_balloon_init(DeviceState *dev, virtio_balloon_conf *conf)
>  {
>      VirtIOBalloon *s;
> @@ -248,9 +394,18 @@ VirtIODevice *virtio_balloon_init(DeviceState *dev, virtio_balloon_conf *conf)
>      s->vdev.set_config = virtio_balloon_set_config;
>      s->vdev.get_features = virtio_balloon_get_features;
>  
> +    if (conf->path || conf->level || conf->granularity > 0) {
> +        ret = host_mempressure_init(s, conf);
> +        if (ret < 0) {
> +            virtio_cleanup(&s->vdev);
> +            return NULL;
> +        }
> +    }
> +
>      ret = qemu_add_balloon_handler(virtio_balloon_to_target,
>                                     virtio_balloon_stat, s);
>      if (ret < 0) {
> +        host_mempressure_cleanup(s);
>          virtio_cleanup(&s->vdev);
>          return NULL;
>      }
> @@ -273,6 +428,7 @@ void virtio_balloon_exit(VirtIODevice *vdev)
>      VirtIOBalloon *s = DO_UPCAST(VirtIOBalloon, vdev, vdev);
>  
>      qemu_remove_balloon_handler(s);
> +    host_mempressure_cleanup(s);
>      unregister_savevm(s->qdev, "virtio-balloon", s);
>      virtio_cleanup(vdev);
>  }
> diff --git a/hw/virtio-balloon.h b/hw/virtio-balloon.h
> index 9d631d5..fcf0e3c 100644
> --- a/hw/virtio-balloon.h
> +++ b/hw/virtio-balloon.h
> @@ -26,6 +26,7 @@
>  /* The feature bitmap for virtio balloon */
>  #define VIRTIO_BALLOON_F_MUST_TELL_HOST 0 /* Tell before reclaiming pages */
>  #define VIRTIO_BALLOON_F_STATS_VQ 1       /* Memory stats virtqueue */
> +#define VIRTIO_BALLOON_F_AUTO_BALLOON 2   /* Automatic ballooning */
>  
>  /* Size of a PFN in the balloon interface. */
>  #define VIRTIO_BALLOON_PFN_SHIFT 12
> @@ -40,6 +41,9 @@ struct virtio_balloon_config
>  
>  typedef struct virtio_balloon_conf
>  {
> +    char *path;
> +    char *level;
> +    uint32_t granularity;
>  } virtio_balloon_conf;
>  
>  /* Memory Statistics */
> diff --git a/hw/virtio-pci.c b/hw/virtio-pci.c
> index 026222b..487b7f2 100644
> --- a/hw/virtio-pci.c
> +++ b/hw/virtio-pci.c
> @@ -991,6 +991,11 @@ static TypeInfo virtio_serial_info = {
>  static Property virtio_balloon_properties[] = {
>      DEFINE_VIRTIO_COMMON_FEATURES(VirtIOPCIProxy, host_features),
>      DEFINE_PROP_HEX32("class", VirtIOPCIProxy, class_code, 0),
> +#ifdef __linux__
> +    DEFINE_PROP_STRING("auto-balloon-mempressure-path", VirtIOPCIProxy, balloon.path),
> +    DEFINE_PROP_STRING("auto-balloon-level", VirtIOPCIProxy, balloon.level),
> +    DEFINE_PROP_UINT32("auto-balloon-granularity", VirtIOPCIProxy, balloon.granularity, 0),
> +#endif
>      DEFINE_PROP_END_OF_LIST(),
>  };
>  
> -- 
> 1.8.0
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
