Received: from Galois.suse.de (Galois.suse.de [195.125.217.193])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA16194
	for <linux-mm@kvack.org>; Mon, 1 Dec 1997 15:39:23 -0500
Date: Mon, 1 Dec 1997 21:33:14 +0100
Message-Id: <199712012033.VAA07814@boole.fs100.suse.de>
From: "Dr. Werner Fink" <werner@suse.de>
In-reply-to: <199712010925.KAA09786@marlene.neurologie.uni-duesseldorf.de>
	(weule@marlene.neurologie.uni-duesseldorf.de)
Subject: Re: shm and locked pages
Sender: owner-linux-mm@kvack.org
To: weule@marlene.neurologie.uni-duesseldorf.de
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


> Hello Kernel-Developers!

Nice idea for stopping foolish syscalls like makeing hugh amount of
memory non-swappable.  But the calculation of your limits is not a win ...
please do not use floats within the kernel ;)

Nevertheless, the idea may explain and solve _some_ seen memory leaks due
locked but never unlocked shm's.

          Werner

> 
> If root is locking more shm pages to physical memory than the computer
> has, the system stopps running because all other pages are swapped out.
> To fix this, I patched ipc/shm.c and decided to limit the locked pages
> to
>         totalram - sqrt(totalram*8MB):
> 
>         /*
>          * Maximal locked shared memory:
>          *    totalmem - sqrt(8MB*totalram) if totalram > 8MB
>          *
>          * Exampes:
>          *
>          * totalram:     8 12.0 16.0 18 20.0 24.0 32 50 64.0 72 128 256
>          * never locked: 8  9.8 11.3 12 12.6 13.9 16 20 22.6 24  32  45
>          * max locked:   0  2.2  4.7  6  7.4 10.1 16 30 41.4 48  96 211
>          *
>          * The formular seem reasonable for me.
>          * t-sqrt(8MB*t)>m  <=3D=3D>  (t-m)*(t-m)-8MB*t>0
>          *
>          *                                  J"org Weule (weule@acm.org)
>          */
> 
> If a program locking half the pages hangs and a second one is started,
> the second will not lock the other half of the memory and the system is =
> still
> up. shm_lock.c is a program to test the number of pages one can lock.
> 
> The number val.totalram (struct sys_meminfo) may be replaced by =
> num_physpages
> at linux-2.1.xx in future releases.
> 
> Hope this helps
> 
> J"org
> -------------------------------------------------------------------------=
> ------
> J=F6rg Weule - weule@uni-duesseldorf.de - =
> http://www.cs.uni-duesseldorf.de/~weule
> --700c_66f6-60f5_4b48-54f0_ec4
> Content-Type: application/octet-stream; name=shm.c.diff-2.0.29
> Content-Transfer-Encoding: 7bit
> Content-MD5: IEgTrE1FgVh9D0rLd+A72Q==
> Content-Description: shm.c.diff-2.0.29
> Content-Disposition: attachment; filename=shm.c.diff-2.0.29
> 
> --- shm.c.orig	Fri Nov 28 15:43:41 1997
> +++ shm.c	Mon Dec  1 10:05:16 1997
> @@ -2,6 +2,7 @@
>   * linux/ipc/shm.c
>   * Copyright (C) 1992, 1993 Krishna Balasubramanian
>   *         Many improvements/fixes by Bruno Haible.
> + *         Limit of locked pages: J"org Weule (weule@acm.org), Nov 1997.
>   * Replaced `struct shm_desc' by `struct vm_area_struct', July 1994.
>   */
>  
> @@ -28,6 +29,7 @@
>  static pte_t shm_swap_in(struct vm_area_struct *, unsigned long, unsigned long);
>  
>  static int shm_tot = 0; /* total number of shared memory pages */
> +static int shm_totlock = 0; /* total number of locked shared memory pages */
>  static int shm_rss = 0; /* number of shared memory pages that are in memory */
>  static int shm_swp = 0; /* number of shared memory pages that are in swap */
>  static int max_shmid = 0; /* every used id is <= max_shmid */
> @@ -47,7 +49,7 @@
>  
>  	for (id = 0; id < SHMMNI; id++)
>  		shm_segs[id] = (struct shmid_ds *) IPC_UNUSED;
> -	shm_tot = shm_rss = shm_seq = max_shmid = used_segs = 0;
> +	shm_tot = shm_totlock = shm_rss = shm_seq = max_shmid = used_segs = 0;
>  	shm_lock = NULL;
>  	return;
>  }
> @@ -191,6 +193,7 @@
>  			shm_swp--;
>  		}
>  	}
> +	if (shp->shm_perm.mode & SHM_LOCKED) shm_totlock -= numpages ;
>  	kfree(shp->shm_pages);
>  	shm_tot -= numpages;
>  	kfree(shp);
> @@ -289,6 +292,7 @@
>  		if (!(ipcp->mode & SHM_LOCKED))
>  			return -EINVAL;
>  		ipcp->mode &= ~SHM_LOCKED;
> +		shm_totlock -= shp->shm_npages;
>  		break;
>  	case SHM_LOCK:
>  /* Allow superuser to lock segment in memory */
> @@ -298,7 +302,31 @@
>  			return -EPERM;
>  		if (ipcp->mode & SHM_LOCKED)
>  			return -EINVAL;
> +		/*
> +		 * Maximal locked shared memory:
> +		 *    totalmem - sqrt(8MB*totalram) if totalram > 8MB
> +		 *
> +		 * Exampes:
> +		 *
> +		 * totalram:     8 12.0 16.0 18 20.0 24.0 32 50 64.0 72 128 256
> +		 * never locked: 8  9.8 11.3 12 12.6 13.9 16 20 22.6 24  32  45
> +		 * max locked:   0  2.2  4.7  6  7.4 10.1 16 30 41.4 48  96 211
> +		 *
> +		 * The formular seem reasonable for me.
> +		 * t-sqrt(8MB*t)>m  <==>  (t-m)*(t-m)-8MB*t>0
> +		 *
> +		 *                                  J"org Weule (weule@acm.org)
> +		 */
> +		{	struct sysinfo val ;
> +			double d ;
> +			si_meminfo(&val);
> +			d = ( shp->shm_npages + shm_totlock ) * PAGE_SIZE ;
> +			d -= val.totalram ;
> +			d = d * d / (1024UL*8192UL) - val.totalram ;
> +			if ( val.totalram < (8192UL*1024UL) || d < 0.0 ) return -EPERM ;
> +		}
>  		ipcp->mode |= SHM_LOCKED;
> +		shm_totlock += shp->shm_npages;
>  		break;
>  	case IPC_STAT:
>  		if (ipcperms (ipcp, S_IRUGO))
> --700c_66f6-60f5_4b48-54f0_ec4
> Content-Type: application/octet-stream; name=shm.c.diff-2.1.66
> Content-Transfer-Encoding: 7bit
> Content-MD5: qS9y3i3sA7ImutlYngf/iw==
> Content-Description: shm.c.diff-2.1.66
> Content-Disposition: attachment; filename=shm.c.diff-2.1.66
> 
> --- shm.c.orig	Mon Dec  1 09:34:44 1997
> +++ shm.c	Mon Dec  1 10:16:29 1997
> @@ -2,6 +2,7 @@
>   * linux/ipc/shm.c
>   * Copyright (C) 1992, 1993 Krishna Balasubramanian
>   *         Many improvements/fixes by Bruno Haible.
> + *         Limit of locked pages: J"org Weule (weule@acm.org), Nov 1997.
>   * Replaced `struct shm_desc' by `struct vm_area_struct', July 1994.
>   */
>  
> @@ -32,6 +33,7 @@
>  static pte_t shm_swap_in(struct vm_area_struct *, unsigned long, unsigned long);
>  
>  static int shm_tot = 0; /* total number of shared memory pages */
> +static int shm_totlock = 0; /* total number of locked shared memory pages */
>  static int shm_rss = 0; /* number of shared memory pages that are in memory */
>  static int shm_swp = 0; /* number of shared memory pages that are in swap */
>  static int max_shmid = 0; /* every used id is <= max_shmid */
> @@ -51,7 +53,7 @@
>  
>  	for (id = 0; id < SHMMNI; id++)
>  		shm_segs[id] = (struct shmid_ds *) IPC_UNUSED;
> -	shm_tot = shm_rss = shm_seq = max_shmid = used_segs = 0;
> +	shm_tot = shm_totlock = shm_rss = shm_seq = max_shmid = used_segs = 0;
>  	shm_lock = NULL;
>  	return;
>  }
> @@ -201,6 +203,7 @@
>  			shm_swp--;
>  		}
>  	}
> +	if (shp->shm_perm.mode & SHM_LOCKED) shm_totlock -= numpages ;
>  	kfree(shp->shm_pages);
>  	shm_tot -= numpages;
>  	kfree(shp);
> @@ -312,6 +315,7 @@
>  		if (!(ipcp->mode & SHM_LOCKED))
>  			goto out;
>  		ipcp->mode &= ~SHM_LOCKED;
> +		shm_totlock -= shp->shm_npages;
>  		break;
>  	case SHM_LOCK:
>  /* Allow superuser to lock segment in memory */
> @@ -323,6 +327,31 @@
>  		err = -EINVAL;
>  		if (ipcp->mode & SHM_LOCKED)
>  			goto out;
> +		/*
> +		 * Maximal locked shared memory:
> +		 *    totalmem - sqrt(8MB*totalram) if totalram > 8MB
> +		 *
> +		 * Exampes:
> +		 *
> +		 * totalram:     8 12.0 16.0 18 20.0 24.0 32 50 64.0 72 128 256
> +		 * never locked: 8  9.8 11.3 12 12.6 13.9 16 20 22.6 24  32  45
> +		 * max locked:   0  2.2  4.7  6  7.4 10.1 16 30 41.4 48  96 211
> +		 *
> +		 * The formular seem reasonable for me.
> +		 * t-sqrt(8MB*t)>m  <==>  (t-m)*(t-m)-8MB*t>0
> +		 *
> +		 *                                  J"org Weule (weule@acm.org)
> +		 */
> +
> +		{	struct sysinfo val ;
> +			double d ;
> +			si_meminfo(&val);
> +			d = ( shp->shm_npages + shm_totlock ) * PAGE_SIZE ;
> +			d -= val.totalram ;
> +			d = d * d / (1024UL*8192UL) - val.totalram ;
> +			if ( val.totalram < (8192UL*1024UL) || d < 0.0 ) return -EPERM ;
> +		}
> +		shm_totlock += shp->shm_npages;
>  		ipcp->mode |= SHM_LOCKED;
>  		break;
>  	case IPC_STAT:
> --700c_66f6-60f5_4b48-54f0_ec4
> Content-Type: text/plain; charset=ISO-8859-1; name=shm_lock.c
> Content-Transfer-Encoding: 7bit
> Content-MD5: Bzn0f2BvObYZBLIoe8l3SQ==
> Content-Description: shm_lock.c
> Content-Disposition: attachment; filename=shm_lock.c
> X-Sun-Data-Type: c-file
> 
> #include <stdlib.h>
> #include <stdio.h>
> #include <sys/types.h>
> #include <sys/ipc.h>
> #include <sys/shm.h>
> #include <sys/wait.h>
> #include <sys/stat.h>
> #include <fcntl.h>
> 
> /*
>  * Tries to lock 200 MB of memory and sleeps the number of seconds
>  * specified by the first parameter. root can test shm with this program.
>  * (C)opyright by J"org Weule (weule@acm.org), Nov 1997.
>  */
> 
> int s[100];
> char*(p[100]);
> 
> int main(int argc,char*argv[]){
> 	int f ;
> 	int pid , st ;
> 	int i , tot = 0 ;
> 	key_t k = IPC_PRIVATE ;
> 	int n = 1024*1024*2 ;
> 	do {
> 		s[0]=shmget(k, n, (int)IPC_CREAT|0600);
> 		if ( s[0] < 0 ) n -= 1024 ;
> 		else break ;
> 	} while( n>1024 );
> 	if ( s[0] < 0 ) printf("shmget->%d\n",s[0]),perror("shmget"),exit(1);
> 	tot += n ;
> 	p[0]=shmat(s[0],NULL,0);
> 	if(0>=shmctl(s[0],IPC_RMID,NULL))puts("RMID 1");
> 	if ( shmctl(s[0],SHM_LOCK,NULL)>=0) puts("lock1");
> 	printf("%d\n",n);
> 	for ( i = 1 ; i < 100 ; i++ ){
> 		s[i]=shmget(k, n, (int)IPC_CREAT|0600);
> 		if ( s[i] < 0 ) printf("shmget->%d\n",s[i]),perror("shmget"),exit(1);
> 		p[i]=shmat(s[i],NULL,0);
> 		if(0>=shmctl(s[i],IPC_RMID,NULL))puts("RMID 1");
> 		if ( shmctl(s[i],SHM_LOCK,NULL)>=0) puts("lock1");
> 		else break ;
> 		tot += n ;
> 		printf("%20d\n",tot);
> 	}
> 	if ( argc > 1 ) sleep(atoi(argv[1]));
> 	else system("ipcs -m"),sleep(60);
> 	exit(0);
> } 
>  
> 
> --700c_66f6-60f5_4b48-54f0_ec4--
> 
