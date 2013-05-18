Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 25B246B0002
	for <linux-mm@kvack.org>; Sat, 18 May 2013 17:15:37 -0400 (EDT)
Message-ID: <5197EF76.2070504@bitsync.net>
Date: Sat, 18 May 2013 23:15:34 +0200
From: Zlatko Calusic <zcalusic@bitsync.net>
MIME-Version: 1.0
Subject: Re: [PATCH 0/9] Reduce system disruption due to kswapd V4
References: <1368432760-21573-1-git-send-email-mgorman@suse.de> <20130515133748.5db2c6fb61c72ec61381d941@linux-foundation.org>
In-Reply-To: <20130515133748.5db2c6fb61c72ec61381d941@linux-foundation.org>
Content-Type: multipart/mixed;
 boundary="------------040308080605020006080106"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

This is a multi-part message in MIME format.
--------------040308080605020006080106
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 15.05.2013 22:37, Andrew Morton wrote:
>>
>>                              3.10.0-rc1  3.10.0-rc1
>>                                 vanilla lessdisrupt-v4
>> Page Ins                       1234608      101892
>> Page Outs                     12446272    11810468
>> Swap Ins                        283406           0
>> Swap Outs                       698469       27882
>> Direct pages scanned                 0      136480
>> Kswapd pages scanned           6266537     5369364
>> Kswapd pages reclaimed         1088989      930832
>> Direct pages reclaimed               0      120901
>> Kswapd efficiency                  17%         17%
>> Kswapd velocity               5398.371    4635.115
>> Direct efficiency                 100%         88%
>> Direct velocity                  0.000     117.817
>> Percentage direct scans             0%          2%
>> Page writes by reclaim         1655843     4009929
>> Page writes file                957374     3982047
>> Page writes anon                698469       27882
>> Page reclaim immediate            5245        1745
>> Page rescued immediate               0           0
>> Slabs scanned                    33664       25216
>> Direct inode steals                  0           0
>> Kswapd inode steals              19409         778
>
> The reduction in inode steals might be a significant thing?
> prune_icache_sb() does invalidate_mapping_pages() and can have the bad
> habit of shooting down a vast number of pagecache pages (for a large
> file) in a single hit.  Did this workload use large (and clean) files?
> Did you run any test which would expose this effect?
>

I did not run specific tests, but I believe I observed exactly this 
issue on the real workload, where even at a moderate load sudden frees 
of pagecache happen quite often. I've attached a small graph where it 
can be easily seen. The snapshot was taken while the server was running 
an unpatched Linus kernel. After the Mel's patch series is applied, I 
can't see anything similar. So it seems that this issue is completely 
gone, Mel's done a wonderful job.

And BTW, V4 continues to be rock stable, running here on many different 
machines, so I look forward seeing this code merged in 3.11.
-- 
Zlatko

--------------040308080605020006080106
Content-Type: image/png;
 name="memory-hourly.png"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="memory-hourly.png"

iVBORw0KGgoAAAANSUhEUgAAAkEAAADBCAIAAABHSfMLAAAABmJLR0QA/wD/AP+gvaeTAAAg
AElEQVR4nO2de1xU1fbAN49M8AUzKpGDlWOpjCDEozvIIJClZijcTO0melOsW4mWZD5CkZTy
ili+sm7mI8t8fDIqSy2vGcZUhtqAWBn4uzlIjMgMoCEg6O+PzRzPnNecmTOPc2bW98NnPsM+
65yz1n7M3mvvdfbxOX36NAIAAAAAqdHQ0ODvbh0AAAAAwGbq6+tramq6+rDevXu7VxsAAAAA
4A+eRPR1txoAAAAAYCfQhwEAAABSBfowAAAAQKpATAcAAAAgUo4ePUpJSU1NJf8LfhgASA+l
Uuns62OcehcAsEpqampqampiYiKi9V4Y8MMAAKBSXV2NnN9TAgAfWltbf/31V39//6amJn9/
ap8FfhjgTpRKZVpaGvFvWloa/G4CAEBw4cKFn376qWfPnsOHD9fpdAqFgiIAfhjgZq5cuVJR
UREREVFeXn716lV3qwMAgIhobGyMjY0NCAhACCUlJdEFwA8D3MyUKVN2796NENq9e/eUKVNw
Ymdn56ZNm5KTk6Ojo1966aWWlhacrlQq586de//9969bt+6pp56Kjo7etWsXQqilpSU3Nzc+
Pj4+Pn7p0qXXrl0jrq9UKt99993ExMThw4e/9957OHHChAnHjx/H39va2mJiYhoaGjiUpHiH
xL9nz5596qmnYmJihg4dOnHixEOHDhEyn3322YMPPjhs2LAnn3yypqYGJ16/fn3FihXx8fFx
cXHbt28nrsNmLweHDh0aPXp0eHj4xIkTz549ixPZ8oFNf7b8YcPWfAMAgVy+fPn7778/SoIi
AH0Y4GYmTZp08ODBS5cuHTp0aNKkSThx27ZtP/zwwwcffHDs2DF/f/+1a9cS8k888cR//vOf
9evXZ2Vlbd269Z133kEIrVu3rr6+/osvvjhw4MCff/65fv168i1KS0s/+OCDkpKSkpISnDJ1
6tQ9e/bg70ePHo2KipLL5XYo/+yzz2ZkZBw/flyn0y1duvSTTz4hDh0+fHjLli2nTp1KTExc
unQpTty8efP//ve/zz///ODBgz/88AMhzGEvGwcOHNixY0dZWdno0aPz8vJwInc+sEHPHzYc
lW8AwBOrMR3QhwFupl+/fn/729+ee+45tVrdt29fnLhnz56CggKFQtGnT58FCxYcPnyYkI+J
iYmKikIIxcXFRURE1NXVIYQOHTq0ePHifv369e/ff8mSJQcPHiTfYsWKFXfffbdMJtuxYwdO
mThxolarxT7Ep59+mp6ebp/yPj4+VVVVZ86caWpquv/++3GHitm0adM999wTEBAwY8aMn376
CSd+8sknubm5ISEhffv2XbRoESHMYS8bubm5AwYMCAwMzMrK+uWXX3Aidz6wQc8fNhyVbwDA
n9bW1rNnz0JMByBepk6devr06alTpxIptbW1KSkpOLw7Pj4ed1SYbt264XqMv3R0dCCELl26
dOedd2KBAQMGXLp0iXx9+jpwjx49xowZs3///qampp9++mn06NH2af7ee+/V19evWLEiJSXl
gQce+OKLL3B6ZWXl9OnT77//fqVSGRERQczpGQyGAQMG4O+Ewtz2snHHHXfgLwEBAcT1ufOB
DXr+sOGofAMAnkBMByABkpKScDA3gUKh2Lt3b58+fXheoV+/frW1tXfffTdCqLa2tl+/fuSj
Pj4+9FOmTp2ak5PTq1evlJQUvGLMQffu3a9du4bF/vzzTyJdqVS+/vrrCKHOzs4vv/wyLy9v
/PjxCKE5c+Y8++yzGzdu7N27N3bRsHxISIher8fLURcvXrTbXjbY8oFNfwxj/uCz2trabr/9
dnKiTfkGAAKBmA5AkkydOnXRokUXLlxob28/ffr0008/zS0/duzYVatW1dfX19fXr1q1auzY
sVZvMWLEiO7du7/xxhvjxo2zKjxs2LCtW7e2tLTU1tYWFBQQ6TNmzPj2229bWlra2tpaWlqC
goJwemtrq1wuDwgIqKmpIRarEEIZGRkrV66sq6traGgoLCy021422PKBTX+rVn/88cednZ3k
RJvyDQAEAjEdgCSZMWNGfHx8VlZWVFRUXl7eY489xi3/wgsvyGSyRx555JFHHpHL5fPmzeNz
lylTply9enXkyJFWJV999dWvvvoqJiZm+vTp5AfaZs6c+c4778TExGg0mq+++uqtt97C6atX
ry4sLIyIiJg2bdpDDz1EyD/77LODBg1KS0sbO3asWq328/Ozz1422PKBTX9u8vLyduzYMWTI
EEpYI/98AwCB+Pr6Jicn48iO5ORkX19qn+WDX8EC7w8DvJDPP//8wIED5EAMV2IwGCZPnvzt
t9+65e5CcG++AV7FyZMn+/fvj1d5a2tr6+vriZl53HbADwO8lPb29o8++mjMmDEuvu/8+fPP
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
+e+VkzsAAAAASUVORK5CYII=
--------------040308080605020006080106--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
