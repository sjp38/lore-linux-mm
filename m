From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 16/18] FS: Socket inode defragmentation
Date: Mon, 7 Apr 2008 23:13:50 -0700
Message-ID: <20080407231350.4ae53204.akpm@linux-foundation.org>
References: <20080404230158.365359425@sgi.com>
	<20080404230229.401345769@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20080404230229.401345769@sgi.com>
Sender: netdev-owner@vger.kernel.org
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, netdev@vger.kernel.org
List-Id: linux-mm.kvack.org

On Fri, 04 Apr 2008 16:02:14 -0700 Christoph Lameter <clameter@sgi.com> wrote:

> From: Christoph Lameter <clameter@sgi.com>
> To: akpm@linux-foundation.org
> Cc: linux-mm@kvack.org
> Cc: Mel Gorman <mel@skynet.ie>
> Cc: andi@firstfloor.org
> Cc: Nick Piggin <npiggin@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Pekka Enberg <penberg@cs.helsinki.fi>

The net people should get to hear about this, I guess..

> Support inode defragmentation for sockets
> 
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> ---
>  net/socket.c |    8 ++++++++
>  1 files changed, 8 insertions(+), 0 deletions(-)
> 
> diff --git a/net/socket.c b/net/socket.c
> index 9d3fbfb..205f450 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -269,6 +269,12 @@ static void init_once(struct kmem_cache *cachep, void *foo)
>  	inode_init_once(&ei->vfs_inode);
>  }
>  
> +static void *sock_get_inodes(struct kmem_cache *s, int nr, void **v)
> +{
> +	return fs_get_inodes(s, nr, v,
> +		offsetof(struct socket_alloc, vfs_inode));
> +}
> +
>  static int init_inodecache(void)
>  {
>  	sock_inode_cachep = kmem_cache_create("sock_inode_cache",
> @@ -280,6 +286,8 @@ static int init_inodecache(void)
>  					      init_once);
>  	if (sock_inode_cachep == NULL)
>  		return -ENOMEM;
> +	kmem_cache_setup_defrag(sock_inode_cachep,
> +			sock_get_inodes, kick_inodes);
>  	return 0;
>  }
>  
